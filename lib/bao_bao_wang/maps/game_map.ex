defmodule BaoBaoWang.Maps.GameMap do
  @moduledoc false

  use Ecto.Schema

  alias BaoBaoWang.Maps.{MapObject, MapTile}

  schema "game_maps" do
    field :name, :string
    field :width, :integer
    field :height, :integer
    has_many :map_tiles, MapTile
    has_many :map_objects, MapObject

    timestamps()
  end
end
