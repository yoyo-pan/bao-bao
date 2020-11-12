defmodule BaoBaoWangWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :bao_bao_wang
  use Absinthe.Phoenix.Endpoint

  socket "/socket", BaoBaoWangWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/relay", BaoBaoWangWeb.RelaySocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "frontend" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static.IndexHtml, at: "/"

  plug Plug.Static,
    at: "/",
    from: "frontend/build/",
    only: ~w(index.html static favicon.ico robots.txt manifest.json)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_bao_bao_wang_key",
    signing_salt: "o4ByvdyR"

  plug CORSPlug

  plug BaoBaoWangWeb.Context
  plug BaoBaoWangWeb.Router
end
