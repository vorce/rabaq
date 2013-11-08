defmodule Rabaq do
  use Application.Behaviour
  
  defrecord RabaqState,
    nconsumers: 2,
    server: nil,
    queue: ""

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    uri = "amqp://guest:guest@localhost:5672/%2f"
    queue = "helloq"
    state = connection(uri) |>
      RabaqState.new.queue(queue).server
    sub = subscription(state.queue)
    
    {:ok, spid} = Rabaq.Supervisor.start_link
    {:ok, opid} = :supervisor.start_child(spid,
      Supervisor.Behaviour.worker(Rabaq.Outputter, []))

    create_consumers(state.nconsumers, state.server.connection, sub, opid)
      |> start_consumers(spid) 

    {:ok, spid, state}
  end

  def stop(_state) do
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
