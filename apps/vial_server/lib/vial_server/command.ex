defmodule VialServer.Command do
@doc ~S"""
Parses the given `line` into a command.

## Examples

    iex> VialServer.Command.parse "CREATE shopping\r\n"
    {:ok, {:create, "shopping"}}

    iex> VialServer.Command.parse "CREATE  shopping  \r\n"
    {:ok, {:create, "shopping"}}

    iex> VialServer.Command.parse "PUT shopping milk 1\r\n"
    {:ok, {:put, "shopping", "milk", "1"}}

    iex> VialServer.Command.parse "GET shopping milk\r\n"
    {:ok, {:get, "shopping", "milk"}}

    iex> VialServer.Command.parse "DELETE shopping eggs\r\n"
    {:ok, {:delete, "shopping", "eggs"}}

Unknown commands or commands with the wrong number of
arguments return an error:

    iex> VialServer.Command.parse "UNKNOWN shopping eggs\r\n"
    {:error, :unknown_command}

    iex> VialServer.Command.parse "GET shopping\r\n"
    {:error, :unknown_command}

""" 
  def parse(line) do
    case String.split(line) do
      ["CREATE", beacker] -> {:ok, {:create, beacker}}
      ["PUT", beacker, key, value] -> {:ok, {:put, beacker, key, value}}
      ["GET", beacker, key] -> {:ok, {:get, beacker, key}}
      ["DELETE", beacker, key] -> {:ok, {:delete, beacker, key}}
      _ -> {:error, :unknown_command}
    end
  end

@doc """
Runs the given command.
"""

  def run(command)

  def run({:create, beacker}) do
    VIALDB.Lab.create_new_beacker(VIALDB.Lab, beacker)
    {:ok, "OK\r\n"}
  end

  def run({:put, beacker, key, value}) do
    get_beacker(beacker, fn pid ->
      VIALDB.Beacker.put(pid, key, value)
      {:ok, "OK\r\n"}
    end)
  end

  def run({:get, beacker, key}) do
    get_beacker(beacker, fn pid ->
      value = VIALDB.Beacker.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end)
  end

  def run({:delete, beacker, key}) do
    get_beacker(beacker, fn pid ->
      VIALDB.Beacker.delete(pid, key)
      {:ok, "OK\r\n"}
    end)
  end

  defp get_beacker(beacker, callback) do
    case VIALDB.Lab.lookup_beacker(VIALDB.Lab, beacker) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
