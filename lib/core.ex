# Functional Core
# A least recently used cache that is developed as a functional core. 
# The functional core is library implementation.
# The functional core should work on data that’s validated and safe. It should be predictable, so it avoids side effects.
# A functional core is means to easily reason about the application core business logic that is the same pattern 
# created by James Edward Gray and Bruce A. Tate found in the book "Designing Elixir Systems with OTP". 
# 
# Design
# The cache uses 
# - an ets table for key/values to store the key, a unique time to live value, and value
# - an ets table to store the time to live values
# Usage
defmodule Cache.Core do
    # Init
    def init(name) do        
        # Create Time to live ets table to store time to live value
        ttl_table = get_ttl_table_name(name) 
        :ets.new(ttl_table, [:named_table, :public, :ordered_set])
        # Create key/value ets table that stores cache key/values
        :ets.new(name, [:named_table, :public, {:read_concurrency, true}])
    end

    # Handle Get - Gets the value of the key that exists in the cache
    # Returns a value if it exists or else an :error atom
    def get(name, key, retreive \\ true) do
        case :ets.lookup(name, key) do
        [{_, _, value}] ->
            # return the value for the specified key
            retreive && retrieve(name,key) 
            value
        [] ->
            # return an error atom if key not found
            :error
        end
    end

    # Handle Put - Updates (or Inserts the value if it does not exist in the cache)
    # Value Data Type Support - can be any of string, atom, list, tuple, integer (1, 0x1F), float, boolean, map, binary
    def put(table, key, value, cache_size) do
        ttl_table = get_ttl_table_name(table)
        delete_time_to_live(ttl_table,table, key)
        unique_value = insert_time_to_live(ttl_table, key)
        :ets.insert(table, {key, unique_value, value})
        clear_cache(ttl_table,table,cache_size)
        :ok
    end

    # Delete Key in cache
    def delete(table, key) do
        ttl_table = get_ttl_table_name(table)
        delete_time_to_live(ttl_table,table, key)
        :ets.delete(table, key)
        :ok
    end

    # Cache cleanup that removes all ets tables
    def cleanup(table) do
        :ets.delete(table)
        :ets.delete(get_ttl_table_name(table))
    end

    # Handle Retreive - Logic for least recently used entries in time to live table and update ttl value in main cache ets table
    defp retrieve(table, key) do
        ttl_table = get_ttl_table_name(table)
        delete_time_to_live(ttl_table,table, key)
        uniq = insert_time_to_live(ttl_table, key)
        :ets.update_element(table, key, [{2, uniq}])
        :ok
    end

    # Delete time to live for ttle table key
    defp delete_time_to_live(ttl_table, table, key) do
        case :ets.lookup(table, key) do
        [{_, old_unique_value, _}] ->
            :ets.delete(ttl_table, old_unique_value)
        _ ->
            nil
        end
    end

    # Insert time to live for ttl table key
    defp insert_time_to_live(ttl_table, key) do
        uniq = :erlang.unique_integer([:monotonic])
        :ets.insert(ttl_table, {uniq, key})
        uniq
    end

    # Gets the ttle table name
    defp get_ttl_table_name(table) do
        ttl_table = :"#{table}_ttl"
        ttl_table
    end

    # Clear cache if the size is greater than original capacity
    defp clear_cache(ttl_table, table, cache_capacity) do
        if :ets.info(table, :size) > cache_capacity do
            #IO.puts "in clear_cache size is greater than cache cache_capacity"
            oldest_timestamp = :ets.first(ttl_table) # used to be  oldest_timestamp = :ets.first(ttl_table)
            [{_, old_key}] = :ets.lookup(ttl_table, oldest_timestamp)
            :ets.delete(ttl_table, oldest_timestamp)
            :ets.delete(table, old_key)
            true
        else
            #IO.puts "in clear_cache size is not greater than cache cache_capacity"
            nil
        end
    end
end