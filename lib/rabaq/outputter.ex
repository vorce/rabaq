defmodule Rabaq.Outputter do
  use GenServer.Behaviour
    
  defrecord OutputterState,
    outdir: Path.expand("."),
    count: 0,
    max: 10000,
    file: nil

  def start_link do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def init([]) do
    :erlang.process_flag(:trap_exit, true)
    {:ok, OutputterState.new}
  end

  def handle_call({:amqp_msg, [ctag, _mtag], payload}, _from, state) do
    state = state.count(state.count + 1)
    state = handle_file(state)
    result = write_to_file(state.file, ctag <> " | " <> payload <> "\n")
    {:reply, result, state}
  end

  def terminate(reason, state) do
    IO.puts "Terminating outputter. Reason: #{reason}"
    File.close(state.file)
    :ok
  end

  def handle_file(state) do
    mode = [:append, :utf8]
    cond do
      state.file == nil ->
        Path.join(state.outdir, get_filename()) |>
          File.open!(mode) |> state.file
      state.count > state.max ->
        File.close(state.file)
        Path.join(state.outdir, get_filename()) |>
          File.open!(mode) |> state.count(0).file
      true ->
        state
    end
  end

  def get_filename() do
    {{y,m,d}, {h,min,s}} = :calendar.local_time
    "rabaq_#{y}-#{m}-#{d}_#{h}.#{min}.#{s}.msg"
  end

  def write_to_file(filepid, payload) do
    IO.write(filepid, payload)
  end
end
