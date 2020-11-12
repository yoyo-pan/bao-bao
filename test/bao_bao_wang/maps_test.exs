defmodule BaoBaoWang.MapsTest do
  use BaoBaoWang.DataCase

  alias BaoBaoWang.Maps

  import BaoBaoWang.Factory

  describe "game_maps" do
    test "get_game_map/1 returns the game map with given id" do
      game_map = insert(:game_map)
      assert Maps.get_game_map(game_map.id) == game_map
    end
  end
end
