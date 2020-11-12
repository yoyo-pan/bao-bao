defmodule BaoBaoWangWeb.Resolvers.Maps do
  @moduledoc false

  alias BaoBaoWang.{Maps, Repo}

  def map(_, %{id: id}, _) do
    {:ok, Maps.get_game_map(id)}
  end

  def map_tiles(%Maps.GameMap{} = game_map, _, _) do
    %{map_tiles: map_tiles} = Repo.preload(game_map, :map_tiles)

    tile_ids =
      map_tiles
      |> Enum.sort_by(&{&1.x, &1.y})
      |> Enum.map(& &1.tile_id)

    {:ok, tile_ids}
  end

  def map_objects(%Maps.GameMap{} = game_map, _, _) do
    %{map_objects: map_objects} = Repo.preload(game_map, :map_objects)
    {:ok, map_objects}
  end
end
