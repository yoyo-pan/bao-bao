defmodule BaoBaoWang.RoomTest do
  use BaoBaoWang.DataCase

  import BaoBaoWang.Factory

  alias BaoBaoWang.{Game, Room}
  alias BaoBaoWang.Room.RoomPlayer

  @init_state %{rooms: %{}, player_room_map: %{}}

  describe "handle_cast :reset" do
    test "resets rooms" do
      state = %{@init_state | rooms: %{1 => %Room{id: 1}}}

      assert Room.handle_cast(:reset, state) == {:noreply, @init_state}
    end
  end

  describe "handle_call :create" do
    test "creates a room" do
      expected_room = %Room{id: 1, players: [%RoomPlayer{id: 1}], host_id: 1, map_id: 1}
      expected_state = %{@init_state | rooms: %{1 => expected_room}, player_room_map: %{1 => 1}}

      assert Room.handle_call({:create, 1}, nil, @init_state) ==
               {:reply, {:ok, expected_room}, expected_state}
    end

    test "creates a room with available ID" do
      rooms = %{1 => %Room{id: 1}, 3 => %Room{id: 3}}
      state = %{@init_state | rooms: rooms}
      expected_room = %Room{id: 2, players: [%RoomPlayer{id: 1}], host_id: 1, map_id: 1}

      expected_state = %{
        state
        | rooms: Map.put(rooms, 2, expected_room),
          player_room_map: %{1 => 2}
      }

      assert Room.handle_call({:create, 1}, nil, state) ==
               {:reply, {:ok, expected_room}, expected_state}
    end

    test "returns error if the user is existed in any room" do
      rooms = %{1 => %Room{id: 1, players: [%RoomPlayer{id: 1}], host_id: 1}}
      state = %{@init_state | rooms: rooms, player_room_map: %{1 => 1}}

      assert Room.handle_call({:create, 1}, nil, state) ==
               {:reply, {:error, :user_is_joined}, state}
    end
  end

  describe "handle_call :get" do
    test "returns room" do
      room = %Room{id: 1}
      state = %{@init_state | rooms: %{1 => room}}

      assert Room.handle_call({:get, 1}, nil, state) == {:reply, {:ok, room}, state}
    end

    test "returns error if the room is not found" do
      assert Room.handle_call({:get, 1}, nil, @init_state) ==
               {:reply, {:error, :room_is_not_found}, @init_state}
    end
  end

  describe "handle_call :list" do
    test "returns room list" do
      rooms = %{1 => %Room{id: 1}, 2 => %Room{id: 2}}
      state = %{@init_state | rooms: rooms}
      expected_result = {:ok, [%Room{id: 1}, %Room{id: 2}]}

      assert Room.handle_call(:list, nil, state) == {:reply, expected_result, state}
    end
  end

  describe "handle_call {:join, room_id, user_id}" do
    test "adds the given user into the room" do
      map = insert(:game_map)
      room = %Room{id: 1, players: [%RoomPlayer{id: 1}], host_id: 1, map_id: map.id}
      state = %{@init_state | rooms: %{1 => room}, player_room_map: %{1 => 1}}
      expected_room = %{room | players: [%RoomPlayer{id: 2}, %RoomPlayer{id: 1}]}
      expected_state = %{state | rooms: %{1 => expected_room}, player_room_map: %{1 => 1, 2 => 1}}

      assert Room.handle_call({:join, 1, 2}, nil, state) ==
               {:reply, {:ok, expected_room}, expected_state}
    end

    test "returns error if the room is full" do
      players = Enum.map([1, 2, 3, 4, 5, 6, 7, 8], &%RoomPlayer{id: &1})
      rooms = %{1 => %Room{id: 1, players: players, host_id: 1}}
      player_room_map = players |> Enum.map(&{&1.id, 1}) |> Enum.into(%{})
      state = %{@init_state | rooms: rooms, player_room_map: player_room_map}

      assert Room.handle_call({:join, 1, 9}, nil, state) ==
               {:reply, {:error, :room_is_full}, state}
    end

    test "returns error if the room is not found" do
      rooms = %{1 => %Room{id: 1}}
      state = %{@init_state | rooms: rooms}

      assert Room.handle_call({:join, 2, 1}, nil, state) ==
               {:reply, {:error, :room_is_not_found}, state}
    end

    test "returns error if the user is existed in any room" do
      rooms = %{
        1 => %Room{id: 1, players: [%RoomPlayer{id: 1}], host_id: 1},
        2 => %Room{id: 2, players: [%RoomPlayer{id: 2}], host_id: 2}
      }

      state = %{@init_state | rooms: rooms, player_room_map: %{1 => 1, 2 => 2}}

      assert Room.handle_call({:join, 2, 1}, nil, state) ==
               {:reply, {:error, :user_is_joined}, state}
    end

    test "returns error if the game of the room is started" do
      map = insert(:game_map)
      room = %Room{id: 1, map_id: map.id}
      {:ok, game_pid} = Game.start_link(room)
      room = %{room | game_pid: game_pid}
      state = %{@init_state | rooms: %{1 => room}}

      assert Room.handle_call({:join, 1, 1}, nil, state) ==
               {:reply, {:error, :game_is_started}, state}
    end
  end

  describe "handle_call {:leave, room_id, user_id}" do
    test "removes the given user from the room" do
      rooms = %{1 => %Room{id: 1, players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2}], host_id: 1}}
      state = %{@init_state | rooms: rooms, player_room_map: %{1 => 1, 2 => 1}}
      expected_room = %Room{id: 1, players: [%RoomPlayer{id: 1}], host_id: 1}
      expected_state = %{state | rooms: %{1 => expected_room}, player_room_map: %{1 => 1}}

      assert Room.handle_call({:leave, 1, 2}, nil, state) ==
               {:reply, {:ok, expected_room}, expected_state}
    end

    test "removes the given user from the room and change the host user" do
      rooms = %{
        1 => %Room{
          id: 1,
          players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2}, %RoomPlayer{id: 3}],
          host_id: 1
        }
      }

      state = %{@init_state | rooms: rooms, player_room_map: %{1 => 1, 2 => 1, 3 => 1}}
      expected_room = %Room{id: 1, players: [%RoomPlayer{id: 2}, %RoomPlayer{id: 3}], host_id: 3}
      expected_state = %{state | rooms: %{1 => expected_room}, player_room_map: %{2 => 1, 3 => 1}}

      assert Room.handle_call({:leave, 1, 1}, nil, state) ==
               {:reply, {:ok, expected_room}, expected_state}
    end

    test "returns error if the room is not found" do
      rooms = %{1 => %Room{id: 1}}
      state = %{@init_state | rooms: rooms}

      assert Room.handle_call({:leave, 2, 1}, nil, state) ==
               {:reply, {:error, :room_is_not_found}, state}
    end

    test "removes the given user from the room and closes the room if it's empty" do
      rooms = %{1 => %Room{id: 1, players: [%RoomPlayer{id: 1}], host_id: 1}}
      state = %{@init_state | rooms: rooms, player_room_map: %{1 => 1}}
      expected_room = %Room{id: 1}

      assert Room.handle_call({:leave, 1, 1}, nil, state) ==
               {:reply, {:ok, expected_room}, @init_state}
    end
  end

  describe "handle_call :close" do
    test "closes the room" do
      room = %Room{id: 1, players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2}], host_id: 1}
      state = %{@init_state | rooms: %{1 => room}, player_room_map: %{1 => 1, 2 => 1}}

      assert Room.handle_call({:close, 1}, nil, state) == {:reply, {:ok, room}, @init_state}
    end

    test "returns error if the room is not found" do
      rooms = %{1 => %Room{id: 1}}
      state = %{@init_state | rooms: rooms}

      assert Room.handle_call({:close, 2}, nil, state) ==
               {:reply, {:error, :room_is_not_found}, state}
    end
  end

  describe "handle_call :find_user_room" do
    test "returns room witch the user is joined" do
      expected_room = %Room{id: 2, players: [%RoomPlayer{id: 2}, %RoomPlayer{id: 3}], host_id: 3}
      rooms = %{1 => %Room{id: 1, players: [%RoomPlayer{id: 1}], host_id: 1}, 2 => expected_room}
      state = %{@init_state | rooms: rooms, player_room_map: %{1 => 1, 2 => 2, 3 => 2}}

      assert Room.handle_call({:find_user_room, 2}, nil, state) ==
               {:reply, {:ok, expected_room}, state}
    end

    test "returns error if the user is not in any room" do
      assert Room.handle_call({:find_user_room, 1}, nil, @init_state) ==
               {:reply, {:error, :room_is_not_found}, @init_state}
    end
  end

  describe "handle_call :start_game" do
    test "starts a new game" do
      map = insert(:game_map)

      room = %Room{
        id: 1,
        players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2, is_ready: true}],
        host_id: 1,
        map_id: map.id
      }

      {:ok, game_pid} = Game.start_link(room)
      room = %{room | game_pid: game_pid}

      Game.start(game_pid)
      Game.stop(game_pid)

      state = %{@init_state | rooms: %{1 => room}, player_room_map: %{1 => 1, 2 => 1}}

      assert {:reply, {:ok, %Room{id: 1, game_pid: game_pid} = updated_room}, updated_state} =
               Room.handle_call({:start_game, room.id}, nil, state)

      assert game_pid
      assert updated_state == put_in(state, [:rooms, room.id], updated_room)
    end

    test "returns error if players are not ready" do
      rooms = %{1 => %Room{id: 1, players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2}], host_id: 1}}
      state = %{@init_state | rooms: rooms}

      assert Room.handle_call({:start_game, 1}, nil, state) ==
               {:reply, {:error, :player_is_not_ready}, state}
    end

    test "returns error if the room is not found" do
      rooms = %{1 => %Room{id: 1, players: [%RoomPlayer{id: 1}], host_id: 1}}
      state = %{@init_state | rooms: rooms}

      assert Room.handle_call({:start_game, 2}, nil, state) ==
               {:reply, {:error, :room_is_not_found}, state}
    end

    test "returns error if the game of the room is already started" do
      map = insert(:game_map)

      room = %Room{
        id: 1,
        players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2}],
        host_id: 1,
        map_id: map.id
      }

      {:ok, game_pid} = Game.start_link(room)
      room = %{room | game_pid: game_pid}
      state = %{@init_state | rooms: %{1 => room}}

      assert Room.handle_call({:start_game, 1}, nil, state) ==
               {:reply, {:error, :game_is_started}, state}
    end

    test "returns error if number of players is not enough" do
      rooms = %{1 => %Room{id: 1, players: [%RoomPlayer{id: 1}], host_id: 1}}
      state = %{@init_state | rooms: rooms}

      assert Room.handle_call({:start_game, 1}, nil, state) ==
               {:reply, {:error, :too_few_players}, state}
    end
  end

  describe "handle_call :set_ready" do
    test "sets player's is_ready to true" do
      room = %Room{id: 1, players: [%RoomPlayer{id: 1, is_ready: false}], host_id: 1}
      state = %{@init_state | rooms: %{1 => room}}
      expected_room = %{room | players: [%RoomPlayer{id: 1, is_ready: true}]}
      expected_state = %{state | rooms: %{1 => expected_room}}

      assert Room.handle_call({:set_ready, 1, 1, true}, nil, state) ==
               {:reply, {:ok, expected_room}, expected_state}
    end

    test "sets player's is_ready to false" do
      room = %Room{id: 1, players: [%RoomPlayer{id: 1, is_ready: true}], host_id: 1}
      state = %{@init_state | rooms: %{1 => room}}
      expected_room = %{room | players: [%RoomPlayer{id: 1, is_ready: false}]}
      expected_state = %{state | rooms: %{1 => expected_room}}

      assert Room.handle_call({:set_ready, 1, 1, false}, nil, state) ==
               {:reply, {:ok, expected_room}, expected_state}
    end

    test "returns error if the room is not found" do
      rooms = %{1 => %Room{id: 1}}
      state = %{@init_state | rooms: rooms}

      assert Room.handle_call({:set_ready, 2, 1, true}, nil, state) ==
               {:reply, {:error, :room_is_not_found}, state}
    end
  end
end
