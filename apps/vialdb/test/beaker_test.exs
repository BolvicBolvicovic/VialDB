defmodule VIALDB.BeackerTest do
  use ExUnit.Case, async: true

  setup do
    beacker = start_supervised!(VIALDB.Beacker)
    %{beacker: beacker}
  end

  test "store values by key", %{beacker: beacker} do
    assert VIALDB.Beacker.get(beacker, "elixir") == nil

    VIALDB.Beacker.put(beacker, "elixir", 1)
    assert VIALDB.Beacker.get(beacker, "elixir") == 1
  end

  test "delete values by key", %{beacker: beacker} do
    VIALDB.Beacker.put(beacker, "javascript", -1)
    assert VIALDB.Beacker.get(beacker, "javascript") == -1

    VIALDB.Beacker.delete(beacker, "javascript")
    assert VIALDB.Beacker.get(beacker, "javascript") == nil
  end
end
