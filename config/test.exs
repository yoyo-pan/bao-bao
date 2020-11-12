use Mix.Config

config :bao_bao_wang, :user_token, BaoBaoWang.UserTokenMock

# Configure your database
config :bao_bao_wang, BaoBaoWang.Repo,
  username: "postgres",
  password: "postgres",
  database: "bao_bao_wang_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bao_bao_wang, BaoBaoWangWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
