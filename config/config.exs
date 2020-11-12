# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bao_bao_wang,
  ecto_repos: [BaoBaoWang.Repo]

config :bao_bao_wang, :user_token, BaoBaoWang.UserToken

config :bao_bao_wang, :game_ticker_interval, 30

# Configures the endpoint
config :bao_bao_wang, BaoBaoWangWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Qs4U0JBsCAMYkKer5m7hfhzEBUr4hUXEVK6RobtcqbXZw+fJfjR9032SLI+WqUIY",
  render_errors: [view: BaoBaoWangWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BaoBaoWang.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
