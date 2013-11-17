defmodule Rabaq.Outputter do
  use GenServer.Behaviour
    
  defrecord OutputterState,
    outdir: Path.expand("."),
    file_count: 0,
    max: 10_000,
    cache: nil,
    consumer_sup: nil

  defrecord OutFile,
    pid: nil,
    count: 0

  def start_link(args) do
    :gen_server.start_link(__MODULE__, args, [])
  end

  def init([max, outdir, count, [con, sub], spid]) do
    #:erlang.process_flag(:trap_exit, true)
    cache = ConCache.start_link(
      ttl_check: :timer.seconds(2),
      ttl: :timer.minutes(10), # TODO: Should be configurable
      touch_on_read: true,
      callback: &cache_callback/1
    )

    self <- {:start_consumer_supervisor, spid, count, [con, sub]}
    {:ok, OutputterState.new.max(max).outdir(outdir).cache(cache)}
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
    {filename, outfile} = out_file(state, payload)
    :ok = outfile.pid |> write_to_file payload <> "\n"

    state = updated_state(state, filename,
      outfile.count(outfile.count + 1)) #handle_file(state, payload)
    {:reply, :ok, state}
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

  def terminate(_reason, _state) do
    :ok
  end

  def out_file(state, payload) do
    mode = [:append, :utf8]
    filename = get_filename(state.file_count)
    {filename, ConCache.get_or_store(state.cache, filename, fn() ->
      Path.join(state.outdir, filename) |> File.open!(mode) |>
        OutFile.new.pid
      end)}
  end

  def updated_state(state, filename, outfile) do
    cond do
      outfile.count >= state.max ->
        ConCache.delete(state.cache, filename)
        state.file_count(state.file_count + 1)
      true ->
        ConCache.update(state.cache, filename, fn(_old) ->
          outfile
        end)
        state
    end
  end

  # TODO: Check for existing files, append number automatically
  def get_filename(count) do
    {{y,m,d}, {_h,_min,_s}} = :calendar.local_time
    "out_#{y}-#{m}-#{d}_#{count}.rbq"
  end

  def write_to_file(filepid, payload) do
    IO.write(filepid, payload)
  end

  def cache_callback(info) do
    case info do
      {:delete, cache, key} ->
        cache_expire(cache, key)
      _ -> # update
        :ok
    end
  end

  def cache_expire(cache, key) do
    outfile = ConCache.get(cache, key)
    File.close(outfile.pid)
    # TODO: Compress file if configured
  end
end
