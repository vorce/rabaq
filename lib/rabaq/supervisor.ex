defmodule Rabaq.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    # create connection to server
    #uri = "amqp://guest:guest@localhost:5672/%2f"
    #queue = "helloq"
    #state = create_connection(uri) |>
    #  RabaqState.new.queue(queue).server
    #sub = create_subscription(state.queue)
    #outer = worker(Rabaq.Outputter, [])
    #consumers = Enum.map(1..state.nconsumers, fn(_) ->
    #              worker(Rabaq.Consumer,
    #                [state.server.connection, sub, outpid])
    #            end)

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Rabaq.Worker, [])
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise(children, strategy: :rest_for_one)
  end
end
