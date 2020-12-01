# Boundary Layer
# Cache Server boundary layer is a GenServer that has state and allows message passing using OTP GenServer. 
# The boundary layer is a user friendly API that a developer can consume in their application.
#
# Usage
# {:ok, server} = Cache.Server.start_link("test",5)
# Cache.Server.put server, "1", "test"
# Cache.Server.get server, "1"
# Cache.Server.stop server
defmodule Cache.Server do
    use GenServer
    # Import Functional core libary that has our Lrucache Business Logic
    alias Cache.Core
    # Client API
    def start_link(cache_name, cache_capacity) when is_integer(cache_capacity) do
        GenServer.start_link(__MODULE__, {cache_name, cache_capacity})
    end

    # Init - State - cache_name and cache_capacity are stored in state of GenServer
    def init({cache_name, cache_capacity}) do 
        # Initialize Functional Core library
        Core.init(String.to_atom(cache_name))
        # Return cache name and cache capacity as our state in GenServer
        {:ok, %{cache_name: cache_name, cache_capacity: cache_capacity}}
    end

    # Gets the value of the key that exists in the cache
    def get(pid, key), do: GenServer.call(pid, {:get, key})
    # Put updates (or Inserts the value if it does not exist in the cache)
    def put(pid, key,value), do: GenServer.cast(pid, {:put, key, value})
    # Stop - For case when we don't have a supervision tree
    def stop(pid), do: GenServer.stop(pid, :normal, :infinity)

    def state(pid) do
        GenServer.call(pid, :state)
    end

    # Server (callbacks)
    def handle_call({:get, key}, _from, state) do
        # Call functional core library to get a value by key
        {:reply, Core.get(String.to_atom(state.cache_name),key), state}
    end

    def handle_cast({:put, key,value}, state) do
        # Call functional core library to put a key/value
        Core.put(String.to_atom(state.cache_name),key,value, :erlang.integer_to_binary(state.cache_capacity)  ) 
        {:noreply, state}
    end

    def terminate(_reason, state) do
        # Cleanup the cache
        Core.cleanup(String.to_atom(state.cache_name))
        :ok
    end
end