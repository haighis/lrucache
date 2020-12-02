# Lrucache

A lease recently used cache that consists of a Lrucache library (functional core), Cache GenServer (boundary layer) and Phoenix REST API.

The cache can be initialized (or configured) with an initial capacity
- The cache should support any type of object being stored in the value including: string, atom, list, tuple, integer (1, 0x1F), float, boolean, map, binary
- The following operations will be supported:
- a. get(key) - Gets the value of the key that exists in the cache
- b. put(key, value) - Updates (or Inserts the value if it does not exist in the cache).
- When the cache capacity has been reached, inserting new keys should result in the least used key being evicted.
- Test coverage

## Running Lrucache Library

```
iex -S mix 

Cache.Core.init(:my)
Cache.Core.handle_put(:my,"1","test", 5)
Cache.Core.handle_put(:my,"2","tester", 5)
Cache.Core.handle_get(:my,"1")
Cache.Core.cleanup(:my)
```

## Running Lrucache GenServer

```
iex -S mix 

{:ok, server} = Cache.Server.start_link("test",5)
Cache.Server.put server, "1", "test"
Cache.Server.get server, "1"
Cache.Server.stop server
```

## Running Phoenix server

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`
- Save a key/value by making a POST request to http://localhost:4000/api/keyvalues
```
wget --quiet \
  --method POST \
  --header 'Content-Type: application/json' \
  --body-data '{"key": "2","value": "kelton"}' \
  --output-document \
  - http://localhost:4000/api/keyvalues
```

- Get a value for key by making a GET request to http://localhost:4000/api/keyvalues

```
wget --quiet \
  --method GET \
  --header 'Content-Type: application/json' \
  --output-document \
  - http://localhost:4000/api/keyvalues/2
```
