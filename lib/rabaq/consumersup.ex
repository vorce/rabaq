defmodule Rabaq.Consumersup do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    # TODO: investigate using :simple_one_for_one
    # and removing some logic in Outputter for adding
    # Consumers to this supervisor.
    supervise([], strategy: :one_for_one)
  end
end
