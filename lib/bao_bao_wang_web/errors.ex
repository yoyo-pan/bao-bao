defmodule BaoBaoWangWeb.Errors do
  @moduledoc false

  def unauthenticated do
    {:error, code: 1, message: "Unauthenticated"}
  end
end
