defmodule Rabaq.Supersup do
  use Supervisor.Behaviour

  def start_link([_, _, _, [_, _]] = args) do
    :supervisor.start_link({:local, :rabaq_supersup}, __MODULE__, args)
  end

  def init([max, dir, count, [con, sub]]) do
    outputter = worker(Rabaq.Outputter,
      [[max, dir, count, [con, sub], self]])
    supervise([outputter], strategy: :rest_for_one)
  end
end
