defmodule CoreGenServerTest do
    use ExUnit.Case
    # System under test/SUT
    import Cache.Server

    test "cache_genserver_startlink_has_correct_state" do
        {val, server} = start_link("test",5)
        assert val == :ok
        result = :sys.get_state(server)   
        assert result.cache_name == "test"
        assert result.cache_capacity == 5
        stop server
    end

    test "cache_genserver_get_returns_value" do
        {_, server} = start_link("test",5)
        put server, 1, "test1"
        result = get server, 1
        assert result == "test1"
        stop server
    end

    test "cache_genserver_stops_correctly" do
        {_, server} = start_link("test",5)
        stop server
        refute Process.alive? server
    end
end