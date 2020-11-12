defmodule BaoBaoWangWeb.GameChannelTest do
  use BaoBaoWangWeb.ChannelCase

  import BaoBaoWang.Factory

  alias BaoBaoWang.{Game, Room}
  alias BaoBaoWangWeb.{GameChannel, UserSocket}

  setup do
    Room.reset()

    insert(:game_map, id: 1)
    user = insert(:user)
    {:ok, room} = Room.create(user.id)

    {:ok, _, socket} =
      UserSocket
      |> socket("users_socket:#{user.id}", %{current_user: user})
      |> subscribe_and_join(GameChannel, "game:#{room.id}")

    %{socket: socket, current_user: user, room: room}
  end

  describe "start_game" do
    test "starts the game and broadcasts start_game message to all players in the room", %{
      socket: socket,
      current_user: current_user,
      room: room
    } do
      guest_id = current_user.id + 1
      Room.join(guest_id, room.id)
      Room.ready(guest_id, room.id)

      ref = push(socket, "start_game", %{})

      assert_broadcast "start_game", %{}
      assert_reply ref, :ok
    end

    test "returns error if users are not ready", %{
      socket: socket,
      current_user: current_user,
      room: room
    } do
      guest_id = current_user.id + 1
      Room.join(guest_id, room.id)

      ref = push(socket, "start_game", %{})

      assert_reply ref, :error
    end

    test "returns error if the user is not in the room", %{
      socket: socket,
      current_user: user,
      room: room
    } do
      Room.leave(user.id, room.id)
      ref = push(socket, "start_game", %{})

      assert_reply ref, :error
    end

    test "returns error if the user is not host", %{
      socket: socket,
      current_user: user,
      room: room
    } do
      Room.leave(user.id, room.id)
      {:ok, new_room} = Room.create(0)
      Room.join(user.id, new_room.id)

      ref = push(socket, "start_game", %{})

      assert_reply ref, :error
    end
  end

  describe "loaded" do
    test "starts game timer and broacasts start_timer to players if the game is ready to start",
         %{
           socket: socket,
           room: room
         } do
      guest_user = insert(:user)
      Room.join(guest_user.id, room.id)
      Room.ready(guest_user.id, room.id)
      {:ok, %{game_pid: game_pid}} = Room.start_game(room.id)
      Game.load_player(game_pid, guest_user.id)

      push(socket, "loaded", %{})

      assert_broadcast "start_timer", %{}
    end

    test "doesn't start game timer if players are not loaded", %{
      socket: socket,
      room: room
    } do
      guest_user = insert(:user)
      Room.join(guest_user.id, room.id)
      Room.ready(guest_user.id, room.id)
      Room.start_game(room.id)

      push(socket, "loaded", %{})

      refute_broadcast "start_timer", %{}
    end

    test "doesn't start game timer if the game is not started", %{
      socket: socket,
      room: room
    } do
      guest_user = insert(:user)
      Room.join(guest_user.id, room.id)

      push(socket, "loaded", %{})

      refute_broadcast "start_timer", %{}
    end
  end
end
