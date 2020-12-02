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

    test "cache_genserver_put_get_returns_value" do
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

    test "cache_genserver_startlink_with_name_has_correct_state" do
        start_link(cache_name: "test", cache_capacity: 5, name: :testname)
        result = :sys.get_state(:testname)   
        assert result.cache_name == "test"
        assert result.cache_capacity == 5
        stop :testname
    end    

    test "cache_genserver_startlink_with_name_put_get_returns_value" do
        start_link(cache_name: "test", cache_capacity: 5, name: :testname)
        GenServer.cast(:testname,{:put, 1, "test1"})
        result = GenServer.call(:testname,{:get, 1})  
        assert result == "test1"
        stop :testname
    end
end