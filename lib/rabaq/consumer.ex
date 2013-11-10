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
    {channel, ctag} = create_channel(connection, sub)
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
        ack(state.channel, mtag)
      true ->
        IO.puts "Yeaaaah. This is not good. Outputter failed, nacking msg"
        nack(state.channel, mtag)
    end
    {:noreply, state.msg_count(state.msg_count + 1)}
  end

  def handle_info({:"basic.cancel", _, _} = reason, state) do
    close(state.channel, state.ctag)
    {:stop, reason, state}
  end

  def handle_info(info, state) do
    IO.puts "Stopping. Unknown message received:"
    IO.inspect info
    close(state.channel, state.ctag)
    {:stop, info, state}
  end

  def terminate(reason, state) do
    IO.puts "Terminating consumer. Reason: #{reason}"
    close(state.channel, state.ctag)
    :ok
  end

  def close(channel, ctag) do
    :"basic.cancel_ok" = :amqp_channel.call(
      channel, :"basic.cancel".new.consumer_tag(ctag))
    :ok = :amqp_channel.close(channel)
  end

  def create_channel(connection, sub) do
    { :ok, channel } = :amqp_connection.open_channel connection
    {:"basic.consume_ok", ctag} = :amqp_channel.subscribe(channel, sub, self)
    {channel, ctag}
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

  def ack(channel, mtag) do
    :amqp_channel.cast(channel,
      :"basic.ack".new.delivery_tag(mtag))
  end

  def nack(channel, mtag) do
    :amqp_channel.cast(channel,
      :"basic.nack".new.delivery_tag(mtag))
  end
end
