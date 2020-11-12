defmodule BaoBaoWang.Maps.MapTile do
  @moduledoc false

  use Ecto.Schema

  alias BaoBaoWang.Maps.{GameMap, Tile}

  @primary_key false

  schema "map_tiles" do
    belongs_to(:game_map, GameMap, primary_key: true)
    field :x, :integer, primary_key: true
    field :y, :integer, primary_key: true
    belongs_to(:tile, Tile)
  end
end
