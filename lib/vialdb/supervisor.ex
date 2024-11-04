defmodule VIALDB.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {VIALDB.Lab, name: VIALDB.Lab},
      {DynamicSupervisor, name: VIALDB.BeackerSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
