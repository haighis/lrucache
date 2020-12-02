defmodule LrucacheApiWeb.KeyValueController do
  use LrucacheApiWeb, :controller
  import Cache.Server
  action_fallback LrucacheApiWeb.FallbackController

  def index(conn, _params) do
    users = [
      %{name: "Joe",
        email: "joe@example.com",
        password: "topsecret",
        stooge: "moe"},
      %{name: "Anne",
        email: "anne@example.com",
        password: "guessme",
        stooge: "larry"},
      %{name: "Franklin",
        email: "franklin@example.com",
        password: "guessme",
        stooge: "curly"},
    ]
    IO.puts "#{inspect(conn)}"

    json conn, users
  end

  def get(conn,%{"key" => key_params}) do
    val = GenServer.call(:mycache, {:get, key_params} )
    json conn |> put_status(:ok), val
  end

  def put(conn, %{"key" => key, "value" => value} = params) do 
    GenServer.cast(:mycache,{:put, key,value})
    json conn |> put_status(:created), params
  end
end
