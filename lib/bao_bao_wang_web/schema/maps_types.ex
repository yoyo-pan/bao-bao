defmodule BaoBaoWangWeb.Schema.MapsTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BaoBaoWangWeb.Resolvers.Maps

  object(:map_object) do
    field :object_id, non_null(:integer)
    field :x, non_null(:integer)
    field :y, non_null(:integer)
  end

  object(:game_map) do
    field :name, non_null(:string)
    field :width, non_null(:integer)
    field :height, non_null(:integer)
    field :tiles, non_null(list_of(non_null(:integer))), resolve: &Maps.map_tiles/3
    field :objects, non_null(list_of(non_null(:map_object))), resolve: &Maps.map_objects/3
  end

  object(:maps_queries) do
    field :map, non_null(:game_map) do
      arg(:id, non_null(:integer))

      resolve(&Maps.map/3)
    end
  end
end
