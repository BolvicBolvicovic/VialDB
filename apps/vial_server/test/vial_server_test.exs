defmodule VialServerTest do
  use ExUnit.Case
  doctest VialServer

  test "greets the world" do
    assert VialServer.hello() == :world
  end
end
