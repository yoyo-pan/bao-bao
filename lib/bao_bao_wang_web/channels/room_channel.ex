defmodule BaoBaoWangWeb.RoomChannel do
  @moduledoc false

  use Phoenix.Channel

  import Absinthe.Relay.Node, only: [to_global_id: 2]

  @impl true
  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("message", %{"body" => body}, socket) do
    %{assigns: %{current_user: current_user}} = socket

    broadcast!(socket, "message", %{body: body, from: current_user.nickname})
    {:noreply, socket}
  end

  @impl true
  def handle_in("typing", %{"isTyping" => is_typing}, socket) when is_boolean(is_typing) do
    %{assigns: %{current_user: current_user}} = socket

    broadcast(socket, "typing", %{
      "isTyping" => is_typing,
      from: to_global_id("User", current_user.id)
    })

    {:noreply, socket}
  end
end
