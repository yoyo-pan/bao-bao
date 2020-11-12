defmodule BaoBaoWangWeb.RelaySocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: BaoBaoWangWeb.Schema

  @user_token_module Application.get_env(:bao_bao_wang, :user_token)

  alias BaoBaoWang.Accounts

  def connect(%{"Authorization" => auth}, socket, _connect_info) do
    ["Bearer", token] = String.split(auth)

    with user_id when user_id != nil <- @user_token_module.from_token(token),
         %Accounts.User{} = user <- Accounts.get_user(user_id) do
      socket = Absinthe.Phoenix.Socket.put_options(socket, context: %{current_user: user})
      {:ok, socket}
    else
      _ -> :error
    end
  end

  def connect(_, _, _) do
    :error
  end

  def id(%{assigns: %{absinthe: %{opts: opts}}}) do
    context = Keyword.fetch!(opts, :context)
    "relay_socket:#{context.current_user.id}"
  end
end
