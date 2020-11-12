defmodule BaoBaoWang.GameTest do
  use BaoBaoWang.DataCase

  import BaoBaoWang.Factory

  alias BaoBaoWang.{Game, Room}
  alias BaoBaoWang.Game.{CommandQueue, GameState, Player}
  alias BaoBaoWang.Room.RoomPlayer

  describe "init/1" do
    test "returns ok with the given game" do
      map = insert(:game_map)
      room = %Room{id: 1, map_id: map.id}
      state = GameState.new()
      expected_game = %Game{room: room, state: state}

      assert Game.init(room) == {:ok, expected_game}
    end
  end

  describe "handle_call :load_player" do
    test "adds loaded player and returns ok" do
      room = %Room{id: 1, host_id: 1, players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2}]}
      init_game = %Game{room: room, state: %GameState{}, loaded_players: [1]}
      expected_game = %{init_game | loaded_players: [2, 1]}

      assert Game.handle_call({:load_player, 2}, nil, init_game) ==
               {:reply, {:ok, expected_game}, expected_game}
    end

    test "returns ok without changes if the user is already loaded" do
      room = %Room{id: 1, host_id: 1, players: [%RoomPlayer{id: 1}]}
      init_game = %Game{room: room, state: %GameState{}, loaded_players: [1]}
      expected_game = %{init_game | loaded_players: [1]}

      assert Game.handle_call({:load_player, 1}, nil, init_game) ==
               {:reply, {:ok, expected_game}, expected_game}
    end

    test "returns ok without changes if the user is not in the game" do
      room = %Room{id: 1, host_id: 1, players: [%RoomPlayer{id: 1}]}
      init_game = %Game{room: room, state: %GameState{}, loaded_players: [1]}
      expected_game = %{init_game | loaded_players: [1]}

      assert Game.handle_call({:load_player, 2}, nil, init_game) ==
               {:reply, {:ok, expected_game}, expected_game}
    end
  end

  describe "handle_call :start" do
    test "starts the game" do
      init_game = %Game{state: %GameState{}}

      assert {:reply, {:ok, game}, game} = Game.handle_call(:start, nil, init_game)
      assert %Game{status: :started, ticker: ticker, command_queue: command_queue} = game
      assert ticker
      assert command_queue
    end
  end

  describe "handle_call :stop" do
    test "stops the game" do
      room = %Room{id: 1}
      state = GameState.new()
      init_game = %Game{status: :started, ticker: self(), room: room, state: state}

      assert {:reply, {:ok, game}, game} = Game.handle_call(:stop, nil, init_game)
      assert %Game{status: :finished, ticker: nil} = game
      assert_received :stop
    end
  end

  describe "handle_call :get" do
    test "returns game" do
      init_game = %Game{}

      assert Game.handle_call(:get, nil, init_game) == {:reply, init_game, init_game}
    end
  end

  describe "handle_call :ready_to_start?" do
    test "returns true if the game is ready to start" do
      room = %Room{id: 1, host_id: 1, players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2}]}
      game = %Game{room: room, state: %GameState{}, loaded_players: [1, 2]}

      assert Game.handle_call(:ready_to_start?, nil, game) == {:reply, true, game}
    end

    test "returns false if players are not loaded" do
      room = %Room{id: 1, host_id: 1, players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2}]}
      game = %Game{room: room, state: %GameState{}, loaded_players: [1]}

      assert Game.handle_call(:ready_to_start?, nil, game) == {:reply, false, game}
    end

    test "returns false if the game is started" do
      room = %Room{id: 1, host_id: 1, players: [%RoomPlayer{id: 1}, %RoomPlayer{id: 2}]}
      game = %Game{room: room, state: %GameState{}, status: :started, loaded_players: [1, 2]}

      assert Game.handle_call(:ready_to_start?, nil, game) == {:reply, false, game}
    end
  end

  describe "handle_cast :tick" do
    test "updates the game state" do
      room = %Room{id: 1}
      {:ok, queue_pid} = CommandQueue.start_link()
      current_time = System.os_time(:millisecond)
      state = %GameState{players: %{1 => %Player{is_alive: true}, 2 => %Player{is_alive: true}}}

      init_game = %Game{
        status: :started,
        ticker: self(),
        command_queue: queue_pid,
        room: room,
        start_time: current_time,
        state: %{state | last_updated_time: current_time}
      }

      assert {:noreply, game} = Game.handle_cast({:tick, 30, current_time}, init_game)
      assert game == init_game
    end

    test "finishs the game if the game is over" do
      [user1, user2] = insert_list(2, :user)
      room = %Room{id: 1}
      current_time = System.os_time(:millisecond)

      state = %GameState{
        players: %{user1.id => %Player{is_alive: true}, user2.id => %Player{is_alive: false}}
      }

      init_game = %Game{
        status: :started,
        ticker: self(),
        room: room,
        start_time: current_time,
        state: state
      }

      expected_game = %{init_game | status: :finished, ticker: nil}

      assert {:noreply, game} = Game.handle_cast({:tick, 30, current_time}, init_game)
      assert game == expected_game
    end
  end

  describe "handle_cast :push_command" do
    test "pushes the command into the command queue" do
      {:ok, queue_pid} = CommandQueue.start_link()
      init_game = %Game{command_queue: queue_pid}
      command = {:key_down, :down, 0}

      assert Game.handle_cast({:push_command, 1, command}, init_game) == {:noreply, init_game}
      assert CommandQueue.all_commands(queue_pid) == [{1, command}]
    end
  end
end
