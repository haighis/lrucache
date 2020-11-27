defmodule CoreTest do
  use ExUnit.Case
  import Cache.Core

  test "init_should_setup_ets_tables_correctly" do
    init(:my)
    assert :ets.info(:my, :size) == 0
    assert :ets.info(:my_ttl, :size) == 0
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "get_with_incorrect_key_should_return_no_value" do
    init(:my)
    # Get a key that does not exist should return an error atom
    assert handle_get(:my,"1") == :error
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "get_should_return_value" do
    init(:my)
    handle_put(:my,"14","test1",1)
    assert handle_get(:my,"14") == "test1"    
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "put_should_return_value" do
    init(:my)
    handle_put(:my,"1","test1",1)
    assert handle_get(:my,"1") == "test1"    
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "cache_capacity_should_be_correct" do
    init(:my)
    # add three items to the cache to validate cache capacity assertion
    handle_put(:my,"1","test1",2)
    handle_put(:my,"2","test1",2)
    handle_put(:my,"3","test1",2)
    assert :ets.info(:my, :size) == 2
    assert :ets.info(:my_ttl, :size) == 2    
    :ets.delete(:my)
    :ets.delete(:my_ttl)
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
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "multiple_data_types_for_key_should_be_supported" do
    init(:my)  
    handle_put(:my,1,"test1",3)
    handle_put(:my,"2","test2",3)
    handle_put(:my,:three,"test3",3)
    [{key1, _, _}] = :ets.lookup(:my, 1)
    assert key1 == 1 
    [{key2, _, _}] = :ets.lookup(:my, "2")
    assert key2 == "2"
    [{key3, _, _}] = :ets.lookup(:my, :three)
    assert key3 == :three
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "handle_put_multiple_data_types_for_values_should_be_supported" do
    init(:my)  
    handle_put(:my,1,1,20) #integer
    handle_put(:my,2,"test2",20) # string
    handle_put(:my,3,:three,20) # atom
    handle_put(:my,4,[1, 2, 3],20) # list
    handle_put(:my,5,{1, 2, 3},20) # tuple
    handle_put(:my,6,0x1F,20) # integer
    handle_put(:my,7,1.0,20) # float
    handle_put(:my,8,true,20) # boolean
    handle_put(:my,9,%{"hello" => "world", a: 1, b: 2},20) # map
    [{_, _, val1}] = :ets.lookup(:my, 1)
    assert val1 == 1 
    [{_, _, val2}] = :ets.lookup(:my, 2)
    assert val2 == "test2"
    [{_, _, val3}] = :ets.lookup(:my, 3)
    assert val3 == :three
    [{_, _, val4}] = :ets.lookup(:my, 4)
    assert val4 == [1, 2, 3]
    [{_, _, val5}] = :ets.lookup(:my, 5)
    assert val5 == {1, 2, 3}
    [{_, _, val6 }] = :ets.lookup(:my, 6)
    assert val6 == 0x1F
    [{_, _, val7}] = :ets.lookup(:my, 7)
    assert val7 == 1.0
    [{_, _, val8}] = :ets.lookup(:my, 8)
    assert val8 == true
    [{_, _, val9}] = :ets.lookup(:my, 9)
    assert val9 == %{"hello" => "world", a: 1, b: 2}
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "handle_get_multiple_data_types_for_values_should_be_supported" do
    init(:my)  
    handle_put(:my,1,1,20) #integer
    handle_put(:my,2,"test2",20) # string
    handle_put(:my,3,:three,20) # atom
    handle_put(:my,4,[1, 2, 3],20) # list
    handle_put(:my,5,{1, 2, 3},20) # tuple
    handle_put(:my,6,0x1F,20) # integer
    handle_put(:my,7,1.0,20) # float
    handle_put(:my,8,true,20) # boolean
    handle_put(:my,9,%{"hello" => "world", a: 1, b: 2},20) # map
    val1 = handle_get(:my,1)
    assert val1 == 1 
    val2 = handle_get(:my, 2)
    assert val2 == "test2"
    val3 = handle_get(:my, 3)
    assert val3 == :three
    val4 = handle_get(:my, 4)
    assert val4 == [1, 2, 3]
    val5 = handle_get(:my, 5)
    assert val5 == {1, 2, 3}
    val6 = handle_get(:my, 6)
    assert val6 == 0x1F
    val7 = handle_get(:my, 7)
    assert val7 == 1.0
    val8 = handle_get(:my, 8)
    assert val8 == true
    val9 = handle_get(:my, 9)
    assert val9 == %{"hello" => "world", a: 1, b: 2}
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "handle_delete_should_delete_values_correctly" do
    init(:my)  
    handle_put(:my,"1","test1",2)
    handle_delete(:my,"1")
    # Assert key in core cache table and ttl table is empty
    assert :ets.info(:my, :size) == 0
    assert :ets.info(:my_ttl, :size) == 0
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end
end
