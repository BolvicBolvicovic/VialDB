defmodule VIALDB do
  @moduledoc """
  Documentation for `VIALDB`.
  """

  use Application

  @impl true
  def start(_type, _args) do
    VIALDB.Supervisor.start_link(name: VIALDB.Supervisor)
  end

end
