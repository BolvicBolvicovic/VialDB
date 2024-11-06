defmodule VIALDB.Lab do
  use GenServer

  ## Client API

  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  def lookup_beacker(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  def create_new_beacker(server, name) do
    GenServer.call(server, {:create, name})
  end

  ## Callbacks

  @impl true
  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:create, name}, _from, {names, refs}) do
    case lookup_beacker(names, name) do
      {:ok, beacker} ->
        {:reply, beacker, {names, refs}}
      :error ->
        {:ok, beacker} = DynamicSupervisor.start_child(VIALDB.BeackerSupervisor, VIALDB.Beacker)
        ref = Process.monitor(beacker)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, beacker})
        {:reply, beacker, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in VIALDB.Lab: #{inspect(msg)}")
    {:noreply, state}
  end
end
