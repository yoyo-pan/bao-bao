defmodule BaoBaoWangWeb.UserSocket do
  use Phoenix.Socket

  @user_token_module Application.get_env(:bao_bao_wang, :user_token)

  alias BaoBaoWang.Accounts

  channel "room:*", BaoBaoWangWeb.RoomChannel
  channel "game:*", BaoBaoWangWeb.GameChannel

  def connect(%{"token" => token}, socket, _connect_info) do
    with user_id when user_id != nil <- @user_token_module.from_token(token),
         %Accounts.User{} = user <- Accounts.get_user(user_id) do
      {:ok, assign(socket, :current_user, user)}
    else
      _ -> :error
    end
  end

  def connect(_, _, _) do
    :error
  end

  def id(socket), do: "users_socket:#{socket.assigns.current_user.id}"
end
