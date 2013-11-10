defmodule Rabaq do
  use Application.Behaviour
  
  defrecord RabaqState,
    nconsumers: 4,
    server: nil,
    queue: "",
    retry_time: 10

  def start(_type, _args) do
    config_file = "rabaq.config.exs"
    config = Rabaq.Config.file! config_file

    server = check_uri(config.uri)
      |> Amqp.Server.new.uri(config.uri).params

    state = RabaqState.new.queue(config.queue).server(server)
      .retry_time(config.retry_timeout).nconsumers(config.consumer_count)
    state = case Amqp.connect(state.server.params) do
      {:ok, c} ->
        Process.monitor(c)
        c
      reason ->
        IO.inspect reason
        raise "Unable to connect to: '#{state.server.uri}'"
    end |> state.server.connection |> state.server

    sub = subscription(state.queue)
    
    {:ok, spid} = Rabaq.Supersup.start_link([config.messages_per_file,
      config.out_directory, state.nconsumers,
        [state.server.connection, sub]])
    {:ok, spid, state}
  end

  def stop(state) do
    :ok = :amqp_connection.close(state.server.connection)
    :ok
  end

  def handle_info({"DOWN", _cref, _process, _con, _reason}, state) do
    retry_connection(state.retry_time * 1000, state)
  end

  def retry_connection(timeout, state) do
    :timer.sleep(timeout)
    case Amqp.connect(state.server.params) do
      {:ok, c} ->
        Process.monitor(c)
        {:noreply, state.server.connection(c)}
      reason ->
        IO.puts "Error connecting to #{state.server.uri}:"
        IO.inspect reason
        IO.puts "Will try again in #{state.retry_time} seconds"
        retry_connection(timeout, state)
    end
  end

  def check_uri(uri) when is_binary(uri) do
    case Amqp.parse_uri(uri) do
      {:ok, p} ->
        p
      reason ->
        IO.inspect reason
        raise "Unable to parse uri '#{uri}'"
    end
  end

  def subscription(queue) do
    :"basic.consume".new.queue(queue)
  end
end
