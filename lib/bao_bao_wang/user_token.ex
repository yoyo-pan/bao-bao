defmodule BaoBaoWang.UserToken do
  @moduledoc false

  alias BaoBaoWang.Token
  alias BaoBaoWangWeb.Endpoint

  @behaviour Token

  @token_salt "user auth"
  @token_max_age 86_400

  @impl true
  def gen_token(user_id) do
    Phoenix.Token.sign(Endpoint, @token_salt, user_id, max_age: @token_max_age)
  end

  @impl true
  def from_token(token) do
    case Phoenix.Token.verify(Endpoint, @token_salt, token, max_age: @token_max_age) do
      {:ok, user_id} -> user_id
      _ -> nil
    end
  end
end
