defmodule BaoBaoWang.Repo do
  use Ecto.Repo,
    otp_app: :bao_bao_wang,
    adapter: Ecto.Adapters.Postgres
end
