defmodule VIALDB.Lab do
  use GenServer

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup_beacker(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create_new_beacker(server, name) do
    GenServer.call(server, {:create, name})
  end

  ## Callbacks

  @impl true
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  def handle_call({:create, name}, _from, state) do
    {names, refs} = state
    if Map.has_key?(names, name) do
      {:reply, :error, state}
    else
      {:ok, beacker} = VIALDB.Beacker.start_link([])
      ref = Process.monitor(beacker)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, beacker)
      {:reply, :ok, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do 
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end


  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in VIALDB.Lab: #{inspect(msg)}")
    {:noreply, state}
  end
end