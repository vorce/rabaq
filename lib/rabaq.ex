defmodule Rabaq do
  use Application.Behaviour
  
  defrecord RabaqState,
    nconsumers: 2,
    server: nil,
    queue: ""

  def start(_type, _args) do
    config_file = "rabaq.config.exs"
    config = Rabaq.Config.file! config_file

    state = connection(config.uri) |>
      RabaqState.new.queue(config.queue)
        .nconsumers(config.consumer_count).server
    sub = subscription(state.queue)
    
    {:ok, spid} = Rabaq.Supervisor.start_link
    {:ok, opid} = :supervisor.start_child(spid,
      Supervisor.Behaviour.worker(Rabaq.Outputter,
        [[config.messages_per_file, config.out_directory]]))

    create_consumers(state.nconsumers, state.server.connection, sub, opid)
      |> start_consumers(spid) 

    {:ok, spid, state}
  end

  def stop(state) do
    :ok = :amqp_connection.close(state.server.connection)
    :ok
  end

  def create_consumers(amount, connection, sub, opid) do
    Enum.map(1..amount,
      &consumer(connection, sub, opid, &1))
  end

  def start_consumers(consumers, spid) do
    Enum.map(consumers, &:supervisor.start_child(spid, &1)) 
  end

  def consumer(connection, sub, opid, instance) do
    Supervisor.Behaviour.worker(Rabaq.Consumer,
      [[connection, sub, opid, instance]], [id: instance])
  end

  def connection(uri) do
    Amqp.Server.new.connect(uri)
  end

  def subscription(queue) do
    :"basic.consume".new.queue(queue)
  end
end
