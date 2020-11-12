defmodule BaoBaoWang.Game.GameStateTest do
  use BaoBaoWang.DataCase

  import Absinthe.Relay.Node, only: [to_global_id: 2]
  import BaoBaoWang.Factory

  alias BaoBaoWang.Game.{Bomb, GameState, Player}

  @players %{
    1 => %Player{x: 2, y: 0, x_progress: 2.0, y_progress: 0.0},
    2 => %Player{x: 17, y: 19, x_progress: 17.0, y_progress: 19.0},
    3 => %Player{x: 18, y: 1, x_progress: 18.0, y_progress: 1.0},
    4 => %Player{x: 1, y: 18, x_progress: 1.0, y_progress: 18.0},
    5 => %Player{x: 10, y: 1, x_progress: 10.0, y_progress: 1.0},
    6 => %Player{x: 9, y: 18, x_progress: 9.0, y_progress: 18.0},
    7 => %Player{x: 6, y: 8, x_progress: 6.0, y_progress: 8.0},
    8 => %Player{x: 13, y: 11, x_progress: 13.0, y_progress: 11.0}
  }

  describe "new/1" do
    test "returns an initialized game state" do
      object = build(:object)

      map_objects = [
        build(:map_object, object: object, x: 0, y: 0),
        build(:map_object, object: object, x: 0, y: 1)
      ]

      params = %{players: [1, 2, 3, 4, 5, 6, 7, 8], map_objects: map_objects}

      assert GameState.new(params) == %GameState{
               players: @players,
               objects: %{{0, 0} => 1, {0, 1} => 1},
               object_info: %{
                 1 => %{walkable: true, destroyable: false}
               }
             }
    end
  end

  describe "update/4" do
    test "returns updated game state" do
      state = GameState.new()
      assert GameState.update(state, [], 0) == state
    end
  end

  describe "zip/1" do
    test "returns zipped game state" do
      current_time = System.os_time(:millisecond)

      state = %GameState{
        players: @players,
        bombs: %{
          {1, 1} => %Bomb{placed_at: current_time, placed_by: 1},
          {2, 2} => %Bomb{placed_at: current_time, placed_by: 2}
        },
        objects: %{
          {0, 0} => 1,
          {0, 1} => 2
        }
      }

      assert GameState.zip(state) == %{
               "players" => %{
                 to_global_id("User", 1) => %{
                   "x" => 2,
                   "y" => 0,
                   "direction" => "down",
                   "bombs" => 3,
                   "isAlive" => true
                 },
                 to_global_id("User", 2) => %{
                   "x" => 17,
                   "y" => 19,
                   "direction" => "down",
                   "bombs" => 3,
                   "isAlive" => true
                 },
                 to_global_id("User", 3) => %{
                   "x" => 18,
                   "y" => 1,
                   "direction" => "down",
                   "bombs" => 3,
                   "isAlive" => true
                 },
                 to_global_id("User", 4) => %{
                   "x" => 1,
                   "y" => 18,
                   "direction" => "down",
                   "bombs" => 3,
                   "isAlive" => true
                 },
                 to_global_id("User", 5) => %{
                   "x" => 10,
                   "y" => 1,
                   "direction" => "down",
                   "bombs" => 3,
                   "isAlive" => true
                 },
                 to_global_id("User", 6) => %{
                   "x" => 9,
                   "y" => 18,
                   "direction" => "down",
                   "bombs" => 3,
                   "isAlive" => true
                 },
                 to_global_id("User", 7) => %{
                   "x" => 6,
                   "y" => 8,
                   "direction" => "down",
                   "bombs" => 3,
                   "isAlive" => true
                 },
                 to_global_id("User", 8) => %{
                   "x" => 13,
                   "y" => 11,
                   "direction" => "down",
                   "bombs" => 3,
                   "isAlive" => true
                 }
               },
               "bombs" => [
                 %{"x" => 1, "y" => 1},
                 %{"x" => 2, "y" => 2}
               ],
               "objects" => [
                 %{"x" => 0, "y" => 0, "id" => 1},
                 %{"x" => 0, "y" => 1, "id" => 2}
               ]
             }
    end
  end
end
