defmodule BaoBaoWangWeb.Schema.Middleware.Auth do
  @moduledoc false

  @behaviour Absinthe.Middleware

  alias Absinthe.Resolution
  alias BaoBaoWang.Accounts.User
  alias BaoBaoWangWeb.Errors

  def call(resolution, _) do
    case resolution.context do
      %{current_user: %User{}} ->
        resolution

      _ ->
        Resolution.put_result(resolution, Errors.unauthenticated())
    end
  end
end
