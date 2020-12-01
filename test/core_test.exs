  defmodule CoreTest do
  use ExUnit.Case
  # System under test/SUT
  import Cache.Core

  test "init_should_setup_ets_tables_correctly" do
      init(:my)
      assert :ets.info(:my, :size) == 0
      assert :ets.info(:my_ttl, :size) == 0
      cleanup(:my)
  end

  test "get_with_incorrect_key_should_return_error_atom" do
      init(:my)
      # Get a key that does not exist should return an error atom
      assert get(:my,"1") == :error
      cleanup(:my)
  end

  test "get_should_return_correct_value" do
      init(:my)
      put(:my,14,"test1",1)
      assert get(:my,14) == "test1"    
      cleanup(:my)
  end

  test "put_should_store_correct_value" do
      init(:my)
      put(:my,1,"test1",1)
      assert get(:my,1) == "test1"    
      cleanup(:my)
  end

  test "cache_capacity_should_be_correct_size" do
      init(:my)
      # add three items to the cache to validate cache capacity assertion
      put(:my,1,"test1",2)
      put(:my,2,"test1",2)
      put(:my,3,"test1",2)
      assert :ets.info(:my, :size) == 2
      assert :ets.info(:my_ttl, :size) == 2    
      cleanup(:my)
  end

  test "get_cache_should_evict_least_recently_used_cache_item" do
      init(:my)
      put(:my,1,"test1",2)
      put(:my,2,"test2",2)
      oldest = get(:my,2) # second most recently used
      newest = get(:my,1) # first most recently used    
      put(:my,3,"test3",2) # put new item that will replace oldest position
      assert newest == "test1"
      assert oldest = :error      
      cleanup(:my)
  end

  test "get_cache_items_should_have_correct_time_to_live_value_based_on_least_recently_used" do
      init(:my)
      put(:my,1,"test1",2)
      put(:my,2,"test2",2)
      get(:my,2) # second most recently used
      get(:my,1) # first most recently used
      [{_,ttl_val_oldest,_}] = :ets.lookup(:my,2)
      [{_,ttl_val_newest,_}] = :ets.lookup(:my,1)
      # oldest ttl value is less than newest ttl value
      assert ttl_val_oldest < ttl_val_newest
      cleanup(:my)
  end

  test "delete_should_delete_values_correctly" do
      init(:my)  
      put(:my,1,"test1",2)
      delete(:my,1)
      # Assert key in core cache table and ttl table is empty
      assert :ets.info(:my, :size) == 0
      assert :ets.info(:my_ttl, :size) == 0
      cleanup(:my)
    end
  end
