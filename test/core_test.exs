defmodule CoreTest do
  use ExUnit.Case
  # System under test/SUT
  import Cache.Core

  test "init_should_setup_ets_tables_correctly" do
    init(:my)
    assert :ets.info(:my, :size) == 0
    assert :ets.info(:my_ttl, :size) == 0
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "get_with_incorrect_key_should_return_error_atom" do
    init(:my)
    # Get a key that does not exist should return an error atom
    assert get(:my,"1") == :error
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "get_should_return_correct_value" do
    init(:my)
    put(:my,14,"test1",1)
    assert get(:my,14) == "test1"    
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "put_should_store_correct_value" do
    init(:my)
    put(:my,1,"test1",1)
    assert get(:my,1) == "test1"    
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "cache_capacity_should_be_correct_size" do
    init(:my)
    # add three items to the cache to validate cache capacity assertion
    put(:my,1,"test1",2)
    put(:my,2,"test1",2)
    put(:my,3,"test1",2)
    assert :ets.info(:my, :size) == 2
    assert :ets.info(:my_ttl, :size) == 2    
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "cache_should_return_recently_used" do
    init(:my)
    put(:my,1,"test1",2)
    put(:my,2,"test2",2)
    put(:my,3,"test3",2)
    get(:my,1)
    assert get(:my,1) == :error
    assert get(:my,2) == "test2"
    assert get(:my,3) == "test3"
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "multiple_data_types_for_key_should_be_supported" do
    init(:my)  
    put(:my,1,"test1",3)
    put(:my,"2","test2",3)
    put(:my,:three,"test3",3)
    [{key1, _, _}] = :ets.lookup(:my, 1)
    assert key1 == 1 
    [{key2, _, _}] = :ets.lookup(:my, "2")
    assert key2 == "2"
    [{key3, _, _}] = :ets.lookup(:my, :three)
    assert key3 == :three
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "put_multiple_data_types_for_values_should_be_supported" do
    cache_name = :my
    cache_size = 10
    init(cache_name)  
    put(cache_name,1,1,cache_size) #integer
    put(cache_name,2,"test2",cache_size) # string
    put(cache_name,3,:three,cache_size) # atom
    put(cache_name,4,[1, 2, 3],cache_size) # list
    put(cache_name,5,{1, 2, 3},cache_size) # tuple
    put(cache_name,6,0x1F,cache_size) # integer
    put(cache_name,7,1.0,cache_size) # float
    put(cache_name,8,true,cache_size) # boolean
    put(cache_name,9,%{"hello" => "world", a: 1, b: 2},cache_size) # map
    put(cache_name,10,<< 65, 68, 75>>,cache_size) # binary
    [{_, _, val1}] = :ets.lookup(cache_name, 1)
    assert val1 == 1 
    [{_, _, val2}] = :ets.lookup(cache_name, 2)
    assert val2 == "test2"
    [{_, _, val3}] = :ets.lookup(cache_name, 3)
    assert val3 == :three
    [{_, _, val4}] = :ets.lookup(cache_name, 4)
    assert val4 == [1, 2, 3]
    [{_, _, val5}] = :ets.lookup(cache_name, 5)
    assert val5 == {1, 2, 3}
    [{_, _, val6 }] = :ets.lookup(cache_name, 6)
    assert val6 == 0x1F
    [{_, _, val7}] = :ets.lookup(cache_name, 7)
    assert val7 == 1.0
    [{_, _, val8}] = :ets.lookup(cache_name, 8)
    assert val8 == true
    [{_, _, val9}] = :ets.lookup(cache_name, 9)
    assert val9 == %{"hello" => "world", a: 1, b: 2}
    [{_, _, val10}] = :ets.lookup(cache_name, 10)
    assert val10 == << 65, 68, 75>>
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end

  test "get_multiple_data_types_for_values_should_be_supported" do
    cache_name = :my
    cache_size = 10
    init(cache_name)  
    put(cache_name,1,1,cache_size) #integer
    put(cache_name,2,"test2",cache_size) # string
    put(cache_name,3,:three,cache_size) # atom
    put(cache_name,4,[1, 2, 3],cache_size) # list
    put(cache_name,5,{1, 2, 3},cache_size) # tuple
    put(cache_name,6,0x1F,cache_size) # integer
    put(cache_name,7,1.0,cache_size) # float
    put(cache_name,8,true,cache_size) # boolean
    put(cache_name,9,%{"hello" => "world", a: 1, b: 2},cache_size) # map
    put(cache_name,10,<< 65, 68, 75>>,cache_size) # binary
    val1 = get(cache_name,1)
    assert val1 == 1 
    val2 = get(cache_name, 2)
    assert val2 == "test2"
    val3 = get(cache_name, 3)
    assert val3 == :three
    val4 = get(cache_name, 4)
    assert val4 == [1, 2, 3]
    val5 = get(cache_name, 5)
    assert val5 == {1, 2, 3}
    val6 = get(cache_name, 6)
    assert val6 == 0x1F
    val7 = get(cache_name, 7)
    assert val7 == 1.0
    val8 = get(cache_name, 8)
    assert val8 == true
    val9 = get(cache_name, 9)
    assert val9 == %{"hello" => "world", a: 1, b: 2}
    val10 = get(cache_name, 10)
    assert val10 == << 65, 68, 75>>
    :ets.delete(cache_name)
    :ets.delete(:my_ttl)
  end

  test "delete_should_delete_values_correctly" do
    init(:my)  
    put(:my,1,"test1",2)
    delete(:my,1)
    # Assert key in core cache table and ttl table is empty
    assert :ets.info(:my, :size) == 0
    assert :ets.info(:my_ttl, :size) == 0
    :ets.delete(:my)
    :ets.delete(:my_ttl)
  end
end
