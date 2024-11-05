defmodule VIALDB.Beacker do
  use Agent, restart: :temporary

  @doc """
  Start a new beacker.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Get a value in the `beacker` by its `key`
  """
  def get(beacker, key) do
    Agent.get(beacker, &Map.get(&1, key))
  end

  @doc """
  Put a `value` in the `beacker` by its `key`
  """
  def put(beacker, key, value) do
    Agent.update(beacker, &Map.put(&1, key, value))
  end

  @doc """
  Delete an element in the `beacker` by its `key` and return its `value`
  """
  def delete(beacker, key) do
    Agent.get_and_update(beacker, &Map.pop(&1, key))
  end
end
