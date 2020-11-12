defmodule BaoBaoWangWeb.Router do
  use BaoBaoWangWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL, schema: BaoBaoWangWeb.Schema
    end

    forward "/", Absinthe.Plug, schema: BaoBaoWangWeb.Schema
  end
end
