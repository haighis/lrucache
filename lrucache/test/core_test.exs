defmodule CoreTest do
  use ExUnit.Case
  import Cache.Core

  test "get_with_incorrect_key_should_return_no_value" do
    init(:my)
    # Get a key that does not exist should return an error atom
    assert handle_get(:my,"1") == :error
  end

  test "get_should_return_value" do
    init(:my)
    handle_put(:my,"14","test1",1)
    assert handle_get(:my,"14") == "test1"    
  end

  test "put_should_return_value" do
    init(:my)
    handle_put(:my,"1","test1",1)
    assert handle_get(:my,"1") == "test1"    
  end

  test "cache_capacity_should_be_correct" do
    init(:my)
    # add three items to the cache to validate cache capacity assertion
    handle_put(:my,"1","test1",2)
    handle_put(:my,"2","test1",2)
    handle_put(:my,"3","test1",2)
    assert :ets.info(:my, :size) == 2
    assert :ets.info(:my_ttl, :size) == 2    
  end

  test "cache_should_return_recently_used" do
    init(:my)
    handle_put(:my,"1","test1",2)
    handle_put(:my,"2","test2",2)
    handle_put(:my,"3","test3",2)
    handle_get(:my,"1")
    assert handle_get(:my,"1") == :error
    assert handle_get(:my,"2") == "test2"
    assert handle_get(:my,"3") == "test3"
  end
end
