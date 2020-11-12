defmodule BaoBaoWangWeb.Resolvers.Accounts do
  @moduledoc false

  alias BaoBaoWang.Accounts

  @user_token_module Application.get_env(:bao_bao_wang, :user_token)

  def viewer(_, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  def login(_, %{input: input}, _) do
    case Accounts.create_or_get_user(input) do
      {:ok, user} ->
        token = @user_token_module.gen_token(user.id)
        {:ok, %{user: user, token: token}}

      result ->
        result
    end
  end

  def update_nickname(_, %{input: input}, %{context: %{current_user: current_user}}) do
    Accounts.update_user(current_user, input)
  end
end
