defmodule BaoBaoWang.Maps.MapObject do
  @moduledoc false

  use Ecto.Schema

  alias BaoBaoWang.Maps.{GameMap, Object}

  @primary_key false

  schema "map_objects" do
    belongs_to(:game_map, GameMap, primary_key: true)
    field :x, :integer, primary_key: true
    field :y, :integer, primary_key: true
    belongs_to(:object, Object)
  end
end
