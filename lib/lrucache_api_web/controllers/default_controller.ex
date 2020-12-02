defmodule LrucacheApiWeb.DefaultController do
  use LrucacheApiWeb, :controller

  def index(conn, _params) do
    text conn, "Welcome to Least Recently Used Cache."
  end
end