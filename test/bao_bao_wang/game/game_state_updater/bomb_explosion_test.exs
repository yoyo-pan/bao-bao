defmodule BaoBaoWang.Game.GameStateUpdater.BombExplosionTest do
  use ExUnit.Case

  alias BaoBaoWang.Game.{Bomb, GameState, Player}
  alias BaoBaoWang.Game.GameStateUpdater.BombExplosion

  test "explodes bombs if the life of the bomb is over" do
    current_time = System.os_time(:millisecond)
    player = %Player{x: 0, y: 0, x_progress: 0.0, y_progress: 0.0, bombs: 0}

    unexploded_bombs = %{
      {1, 1} => %Bomb{placed_at: current_time - 500, placed_by: 1}
    }

    exploded_bombs = %{
      {3, 5} => %Bomb{placed_at: current_time - 1_000, placed_by: 1},
      {3, 3} => %Bomb{placed_at: current_time - 2_000, placed_by: 1},
      {4, 4} => %Bomb{placed_at: current_time - 3_000, placed_by: 1}
    }

    bombs = Map.merge(unexploded_bombs, exploded_bombs)
    state = %GameState{players: %{1 => player}, bombs: bombs}
    expected_player = %{player | bombs: 3}
    expected_state = %{state | players: %{1 => expected_player}, bombs: unexploded_bombs}

    assert BombExplosion.update(state, 30, current_time) == expected_state
  end

  test "explodes bombs and kills player if the player is in the explosion area" do
    current_time = System.os_time(:millisecond)
    player = %Player{x: 0, y: 0, x_progress: 0.0, y_progress: 0.0, bombs: 2}

    bombs = %{
      {0, 1} => %Bomb{placed_at: current_time - 2_000, placed_by: 1}
    }

    state = %GameState{players: %{1 => player}, bombs: bombs}
    expected_player = %{player | bombs: 3, is_alive: false}
    expected_state = %{state | players: %{1 => expected_player}, bombs: %{}}

    assert BombExplosion.update(state, 30, current_time) == expected_state
  end

  test "doesn't kill player if the player is behind the object" do
    current_time = System.os_time(:millisecond)
    player = %Player{x: 0, y: 0, x_progress: 0.0, y_progress: 0.0, bombs: 0}
    bombs = %{{0, 2} => %Bomb{placed_at: current_time - 3_000, placed_by: 1}}
    objects = %{{0, 1} => 1}
    object_info = %{1 => %{walkable: false, destroyable: false}}

    state = %GameState{
      players: %{1 => player},
      bombs: bombs,
      objects: objects,
      object_info: object_info
    }

    expected_player = %{player | bombs: 1}
    expected_state = %{state | players: %{1 => expected_player}, bombs: %{}}

    assert BombExplosion.update(state, 30, current_time) == expected_state
  end

  test "destroys objects if the exploded object is destroyable" do
    current_time = System.os_time(:millisecond)
    player = %Player{x: 0, y: 0, x_progress: 0.0, y_progress: 0.0, bombs: 0}
    bombs = %{{1, 1} => %Bomb{placed_at: current_time - 3_000, placed_by: 1}}
    objects = %{{1, 2} => 1, {2, 1} => 2}

    object_info = %{
      1 => %{walkable: false, destroyable: false},
      2 => %{walkable: false, destroyable: true}
    }

    state = %GameState{
      players: %{1 => player},
      bombs: bombs,
      objects: objects,
      object_info: object_info
    }

    expected_player = %{player | bombs: 1}
    expected_objects = %{{1, 2} => 1}

    expected_state = %{
      state
      | players: %{1 => expected_player},
        bombs: %{},
        objects: expected_objects
    }

    assert BombExplosion.update(state, 30, current_time) == expected_state
  end
end
