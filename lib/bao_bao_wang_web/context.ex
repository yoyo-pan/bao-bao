defmodule BaoBaoWangWeb.Context do
  @moduledoc false

  @behaviour Plug

  import Plug.Conn

  alias BaoBaoWang.Accounts

  @user_token_module Application.get_env(:bao_bao_wang, :user_token)

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
    with user_id when user_id != nil <- @user_token_module.from_token(token),
         %Accounts.User{} = user <- Accounts.get_user(user_id) do
      {:ok, user}
    else
      _ -> {:error, "Invalid authorization token"}
    end
  end
end
