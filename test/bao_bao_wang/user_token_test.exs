defmodule BaoBaoWang.UserTokenTest do
  use BaoBaoWang.DataCase

  alias BaoBaoWang.UserToken
  alias BaoBaoWangWeb.Endpoint

  @token_salt "user auth"
  @token_max_age 86_400

  test "gen_token/1 generates a token" do
    token = UserToken.gen_token(1)

    assert String.length(token) == 96
    assert Phoenix.Token.verify(Endpoint, @token_salt, token, max_age: @token_max_age) == {:ok, 1}
  end

  test "from_token/1 returns user ID" do
    token = Phoenix.Token.sign(Endpoint, @token_salt, 1, max_age: @token_max_age)

    assert UserToken.from_token(token) == 1
  end

  test "from_token/1 returns nil if the token is invalid" do
    assert UserToken.from_token("invalid") == nil
  end
end
