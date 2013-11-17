defmodule Rabaq.Consumer do
  use GenServer.Behaviour

  defrecord ConsumerState,
    channel: nil,
    ctag: "",
    out_pid: nil,
    msg_count: 0

  def start_link(args) do
    :gen_server.start_link(__MODULE__, args, [])
  end

  def init([connection, sub, out_pid, instance]) do
    :erlang.process_flag(:trap_exit, true)
    {channel, ctag} = Amqp.create_channel(connection, sub)
    state = ConsumerState.new.channel(channel).ctag(ctag).out_pid(out_pid)
    IO.puts("Starting consumer #{instance} with tag: #{ctag}")
    {:ok, state}
  end

  def init(_args) do
    {:stop, _args}
  end

  def handle_info({:"basic.consume_ok", _ctag}, state) do
    {:noreply, state}
  end

  def handle_info({{:"basic.deliver", _ctag, mtag, _, _, _from},
                  {:amqp_msg, _, content}}, state) do
    #IO.puts "Delivery from #{from}. Payload: '#{content}'"
    result = out(state, mtag, content)

    cond do
      result == :ok ->
        Amqp.ack(state.channel, mtag)
      true ->
        IO.puts "Yeaaaah. This is not good. Outputter failed, nacking msg"
        Amqp.nack(state.channel, mtag)
    end
    {:noreply, state.msg_count(state.msg_count + 1)}
  end

  def handle_info({:"basic.cancel", _, _} = reason, state) do
    Amqp.close_channel(state.channel, state.ctag)
    {:stop, reason, state}
  end

  def handle_info(info, state) do
    IO.puts "Stopping. Unknown message received:"
    IO.inspect info
    Amqp.close_channel(state.channel, state.ctag)
    {:stop, info, state}
  end

  def terminate(_reason, state) do
    IO.puts "Terminating consumer"
    Amqp.close_channel(state.channel, state.ctag)
    :ok
  end

  def out(state, mtag, content) do
    cond do
      state.out_pid != nil ->
        :gen_server.call(state.out_pid,
          {:amqp_msg, [state.ctag, mtag], content})
      state.out_pid == nil ->
        :ok
    end
  end
end
