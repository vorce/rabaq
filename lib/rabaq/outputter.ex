defmodule Rabaq.Outputter do
  use GenServer.Behaviour
    
  defrecord OutputterState,
    outdir: Path.expand("."),
    count: 0,
    max: 10_000,
    file: nil,
    consumer_sup: nil

  def start_link(args) do
    :gen_server.start_link(__MODULE__, args, [])
  end

  def init([max, outdir, count, [con, sub], spid]) do
    #:erlang.process_flag(:trap_exit, true)
    self <- {:start_consumer_supervisor, spid, count, [con, sub]}
    {:ok, OutputterState.new.max(max).outdir(outdir)}
  end

  def handle_info({:start_consumer_supervisor, spid, count, [con, sub]}, state) do
    consup = Supervisor.Behaviour.supervisor(Rabaq.Consumersup,
      [], restart: :permanent)
    {:ok, pid} = :supervisor.start_child(spid, consup)
    Enum.each(create_consumers(count, con, sub, self),
      &start_consumer(&1, pid))
    #Process.link(pid) ?
    {:noreply, state.consumer_sup(pid)}
  end

  def handle_call({:amqp_msg, [_ctag, _mtag], payload}, _from, state) do
    state = state.count(state.count + 1)
    state = handle_file(state)
    result = write_to_file(state.file, payload <> "\n")
    {:reply, result, state}
  end

  def create_consumers(amount, connection, sub, opid) do
    Enum.map(1..amount,
      &consumer(connection, sub, opid, &1))
  end

  def start_consumer(consumer, spid) do
    :supervisor.start_child(spid, consumer)
  end

  def consumer(connection, sub, opid, instance) do
    Supervisor.Behaviour.worker(Rabaq.Consumer,
      [[connection, sub, opid, instance]], [id: instance])
  end

  def terminate(_reason, state) do
    File.close(state.file)
    :ok
  end

  def handle_file(state) do
    mode = [:append, :utf8]
    cond do
      state.file == nil ->
        Path.join(state.outdir, get_filename()) |>
          File.open!(mode) |> state.file
      state.count >= state.max ->
        File.close(state.file)
        Path.join(state.outdir, get_filename()) |>
          File.open!(mode) |> state.count(0).file
      true ->
        state
    end
  end

  def get_filename() do
    {{y,m,d}, {h,min,s}} = :calendar.local_time
    "rabaq_#{y}-#{m}-#{d}_#{h}.#{min}.#{s}.rbq"
  end

  def write_to_file(filepid, payload) do
    IO.write(filepid, payload)
  end
end
