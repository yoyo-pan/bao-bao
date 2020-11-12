defmodule BaoBaoWangWeb.RoomChannelTest do
  use BaoBaoWangWeb.ChannelCase

  import BaoBaoWang.Factory
  import Absinthe.Relay.Node, only: [to_global_id: 2]

  alias BaoBaoWangWeb.{RoomChannel, UserSocket}

  setup do
    user = insert(:user)

    {:ok, _, socket} =
      UserSocket
      |> socket("users_socket:#{user.id}", %{current_user: user})
      |> subscribe_and_join(RoomChannel, "room:lobby")

    %{socket: socket, current_user: user}
  end

  describe "message" do
    test "broadcasts message", %{socket: socket, current_user: %{nickname: nickname}} do
      push(socket, "message", %{"body" => "message"})
      assert_broadcast "message", %{body: "message", from: ^nickname}
    end
  end

  describe "typing" do
    test "broadcasts isTyping by a boolean variable", %{socket: socket, current_user: %{id: id}} do
      push(socket, "typing", %{"isTyping" => true})
      global_id = to_global_id("User", id)
      assert_broadcast "typing", %{"isTyping" => true, from: ^global_id}
    end
  end
end
