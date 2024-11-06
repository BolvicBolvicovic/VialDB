defmodule VIALDB.LabTest do
  use ExUnit.Case, async: true

  setup context do
    _ = start_supervised!({VIALDB.Lab, name: context.test})
    %{lab: context.test}
  end

  test "create a new beaker in lab", %{lab: lab} do
    assert VIALDB.Lab.lookup_beacker(lab, "The Best Beaker For The Best Elixir") == :error

    VIALDB.Lab.create_new_beacker(lab, "The Best Beaker For The Best Elixir")
    assert {:ok, beacker} = VIALDB.Lab.lookup_beacker(lab, "The Best Beaker For The Best Elixir")

    VIALDB.Beacker.put(beacker, "Some Juicy Elixir", 42)
    assert VIALDB.Beacker.get(beacker, "Some Juicy Elixir") == 42
  end

  test "delete a beacker in lab", %{lab: lab} do
    VIALDB.Lab.create_new_beacker(lab, "Bad Beacker for Bad Lang")
    assert {:ok, beacker} = VIALDB.Lab.lookup_beacker(lab, "Bad Beacker for Bad Lang")
    Agent.stop(beacker)
    assert VIALDB.Lab.lookup_beacker(lab, "Bad Beacker for Bad Lang") == :error
  end

  test "delete a beacker on crash in lab", %{lab: lab} do
    _ = VIALDB.Lab.create_new_beacker(lab, "Bad Beacker for Bad Lang")
    assert {:ok, beacker} = VIALDB.Lab.lookup_beacker(lab, "Bad Beacker for Bad Lang")

    Agent.stop(beacker, :shutdown)
    
    assert VIALDB.Lab.lookup_beacker(lab, "Bad Beacker for Bad Lang") == :error
  end
end
