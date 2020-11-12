defmodule BaoBaoWang.Game.BombTest do
  use ExUnit.Case

  alias BaoBaoWang.Game.Bomb

  describe "exploded?/2" do
    test "returns true if the bomb is exploded" do
      current_time = System.os_time(:millisecond)
      bomb = %Bomb{placed_at: current_time - 2_000}

      assert Bomb.exploded?(bomb, current_time)
    end

    test "returns false if the bomb is not exploded" do
      current_time = System.os_time(:millisecond)
      bomb = %Bomb{placed_at: current_time - 1_999}

      refute Bomb.exploded?(bomb, current_time)
    end
  end
end
