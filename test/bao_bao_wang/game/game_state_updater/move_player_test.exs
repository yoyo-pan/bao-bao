defmodule BaoBaoWang.Game.GameStateUpdater.MovePlayerTest do
  use ExUnit.Case

  alias BaoBaoWang.Game.{GameState, Player}
  alias BaoBaoWang.Game.GameStateUpdater.MovePlayer

  test "ignores if the direction is invalid" do
    player = %Player{x: 0, y: 0, x_progress: 0.0, y_progress: 0.0, key_down: "invalid"}
    state = %GameState{players: %{1 => player}}

    assert MovePlayer.update(state, 30, 0) == state
  end

  test "ignores if the player is dead" do
    player = %Player{
      x: 0,
      y: 0,
      x_progress: 0.0,
      y_progress: 0.0,
      key_down: "down",
      is_alive: false
    }

    state = %GameState{players: %{1 => player}}

    assert MovePlayer.update(state, 30, 0) == state
  end

  test "changes player's position and moves player up" do
    player = %Player{x: 0, y: 10, x_progress: 0.0, y_progress: 10.0, key_down: "up"}
    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :up, y: 9, y_progress: 9.88}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "moves player up" do
    player = %Player{
      x: 0,
      y: 10,
      x_progress: 0.0,
      y_progress: 10.01,
      key_down: "up",
      direction: :up
    }

    state = %GameState{players: %{1 => player}}
    expected_player = %{player | y: 10, y_progress: 10.0}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "changes direction to up only if the player is at border" do
    player = %Player{x: 0, y: 0, x_progress: 0.0, y_progress: 0.0, key_down: "up"}
    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :up}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "changes player's position and moves player down" do
    player = %Player{x: 0, y: 10, x_progress: 0.0, y_progress: 10.0, key_down: "down"}
    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :down, y: 11, y_progress: 10.12}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "moves player down" do
    player = %Player{
      x: 0,
      y: 10,
      x_progress: 0.0,
      y_progress: 9.99,
      key_down: "down",
      direction: :down
    }

    state = %GameState{players: %{1 => player}}
    expected_player = %{player | y: 10, y_progress: 10.0}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "changes direction to down only if the player is at border" do
    player = %Player{x: 0, y: 19, x_progress: 0.0, y_progress: 19.0, key_down: "down"}
    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :down}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "changes player's position and moves player left" do
    player = %Player{x: 10, y: 0, x_progress: 10.0, y_progress: 0.0, key_down: "left"}
    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :left, x: 9, x_progress: 9.88}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "moves player left" do
    player = %Player{
      x: 10,
      y: 0,
      x_progress: 10.01,
      y_progress: 0.0,
      key_down: "left",
      direction: :left
    }

    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :left, x: 10, x_progress: 10.0}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "changes direction to left only if the player is at border" do
    player = %Player{x: 0, y: 0, x_progress: 0.0, y_progress: 0.0, key_down: "left"}
    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :left}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "changes player's position and moves player right" do
    player = %Player{x: 10, y: 0, x_progress: 10.0, y_progress: 0.0, key_down: "right"}
    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :right, x: 11, x_progress: 10.12}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "moves player right" do
    player = %Player{
      x: 10,
      y: 0,
      x_progress: 9.99,
      y_progress: 0.0,
      key_down: "right",
      direction: :right
    }

    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :right, x: 10, x_progress: 10.0}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end

  test "changes direction to right only if the player is at border" do
    player = %Player{x: 19, y: 0, x_progress: 19.0, y_progress: 0.0, key_down: "right"}
    state = %GameState{players: %{1 => player}}
    expected_player = %{player | direction: :right}
    expected_state = %{state | players: %{1 => expected_player}}

    assert MovePlayer.update(state, 30, 0) == expected_state
  end
end
