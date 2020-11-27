# Functional Core
# A least recently used cache that is developed with a functional core. 
# The functional core is library implementation.
# The functional core should work on data that’s validated and safe. It should be predictable, so it avoids side effects.
# A functional core is means to easily reason
# about the application core business logic that is the same pattern 
# created by James Edward Gray and Bruce A. Tate found in the book "Designing Elixir Systems with OTP". 
# 
# Design
# The cache uses 
# - an ets table for key/values to store the key, a unique time to live value, and value
# - an ets table to store the time to live values
# Usage
defmodule Cache.Core do
    def init(name) do        
        # Create Time to live ets table to store time to live value
        ttl_table = get_ttl_table_name(name) 
        :ets.new(ttl_table, [:named_table, :public, :ordered_set])
        # Create key/value ets table that stores cache key/values
        :ets.new(name, [:named_table, :public, {:read_concurrency, true}])
    end

    def handle_get(name, key, retreive \\ true) do
        case :ets.lookup(name, key) do
        [{_, _, value}] ->
            # return the value for the specified key
            value
        [] ->
            # return an error atom if key not found
            :error
        end
    end

    def handle_put(table, key, value, cache_size) do
    end

    def handle_retrieve(table, key) do
    end

    def handle_delete(table, key) do
    end

    defp delete_time_to_live(ttl_table, table, key) do        
    end

    defp insert_time_to_live(ttl_table, key) do        
    end

    defp get_ttl_table_name(table) do
        ttl_table = :"#{table}_ttl"
        ttl_table
    end

    defp clear_cache(ttl_table, table, cache_capacity) do
        # Clear cache if the size is greater than original capacity
        if :ets.info(table, :size) > cache_capacity do
            true
        else
            nil
        end
    end
end