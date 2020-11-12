defmodule BaoBaoWang.Token do
  @moduledoc false

  @callback gen_token(integer()) :: String.t()
  @callback from_token(String.t()) :: integer() | nil
end
