defmodule BaoBaoWang.Game.CommandHandlerTest do
  use ExUnit.Case

  alias BaoBaoWang.Game.{Bomb, CommandHandler, GameState, Player}

  describe "handle unknown command" do
    test "returns the game state directly" do
      state = %GameState{players: %{}}
      assert CommandHandler.apply_command(state, {1, {nil, nil, 0}}) == state
    end
  end

  describe "handle :key_down command" do
    test "sets key_down field to the player" do
      player = %Player{}
      state = %GameState{players: %{1 => player}}
      expected_state = %{state | players: %{1 => %{player | key_down: :up}}}

      assert CommandHandler.apply_command(state, {1, {:key_down, :up, 0}}) == expected_state
    end
  end

  describe "handle :key_up command" do
    test "clears key_down field if the key is the same" do
      player = %Player{key_down: :up}
      state = %GameState{players: %{1 => player}}
      expected_state = %{state | players: %{1 => %{player | key_down: nil}}}

      assert CommandHandler.apply_command(state, {1, {:key_up, :up, 0}}) == expected_state
    end

    test "ignores if the key is not the same" do
      player = %Player{key_down: :down}
      state = %GameState{players: %{1 => player}}

      assert CommandHandler.apply_command(state, {1, {:key_up, :up, 0}}) == state
    end
  end

  describe "handle :place_bomb command" do
    test "places a bomb at current position" do
      current_time = System.os_time(:millisecond)
      player = %Player{x: 10, y: 10}
      state = %GameState{players: %{1 => player}}
      expected_player = %{player | bombs: 2}
      expected_bomb = %Bomb{placed_at: current_time, placed_by: 1}

      expected_state = %{
        state
        | players: %{1 => expected_player},
          bombs: %{{10, 10} => expected_bomb}
      }

      assert CommandHandler.apply_command(state, {1, {:place_bomb, nil, current_time}}) ==
               expected_state
    end

    test "ignores if there's another bomb has been placed at current position" do
      current_time = System.os_time(:millisecond)
      player = %Player{x: 10, y: 10}
      bomb = %Bomb{placed_at: current_time, placed_by: 2}
      state = %GameState{players: %{1 => player}, bombs: %{{10, 10} => bomb}}

      assert CommandHandler.apply_command(state, {1, {:place_bomb, nil, current_time}}) ==
               state
    end

    test "ignores if the player do not have enough bombs to place" do
      current_time = System.os_time(:millisecond)
      player = %Player{x: 10, y: 10, bombs: 0}
      state = %GameState{players: %{1 => player}}

      assert CommandHandler.apply_command(state, {1, {:place_bomb, nil, current_time}}) ==
               state
    end

    test "ignores if the player is dead" do
      current_time = System.os_time(:millisecond)
      player = %Player{x: 10, y: 10, bombs: 2, is_alive: false}
      state = %GameState{players: %{1 => player}}

      assert CommandHandler.apply_command(state, {1, {:place_bomb, nil, current_time}}) ==
               state
    end
  end
end
