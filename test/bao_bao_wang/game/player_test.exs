defmodule BaoBaoWang.Game.PlayerTest do
  use ExUnit.Case

  alias BaoBaoWang.Game.Player

  describe "moving?/1" do
    test "returns true if the player is moving" do
      Enum.each(
        [
          %Player{x: 0, y: 0, x_progress: 1.0, y_progress: 0.0},
          %Player{x: 0, y: 0, x_progress: 0.0, y_progress: 1.0},
          %Player{x: 0, y: 0, x_progress: 1.0, y_progress: 1.0}
        ],
        fn player ->
          assert Player.moving?(player)
        end
      )
    end
  end
end
