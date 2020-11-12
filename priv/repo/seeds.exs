# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BaoBaoWang.Repo.insert!(%BaoBaoWang.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query

alias BaoBaoWang.{Maps, Repo}

tiles = [
  %Maps.Tile{id: 1, walkable: true}
]

objects = [
  %Maps.Object{id: 1, walkable: false},
  %Maps.Object{id: 2, walkable: false, destroyable: true}
]

game_maps = [
  %{
    map: %Maps.GameMap{name: "Village 10", width: 20, height: 20},
    tiles: [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ],
    objects: [
      [0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 2, 0, 1, 2, 1, 2, 1, 0, 1],
      [0, 1, 2, 1, 2, 1, 2, 1, 2, 2, 0, 0, 1, 2, 2, 2, 2, 0, 0, 0],
      [0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 0, 1, 2, 1, 2, 1, 0, 1],
      [2, 1, 2, 1, 2, 1, 2, 1, 2, 2, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 2, 0, 1, 2, 1, 2, 1, 2, 1],
      [2, 1, 2, 1, 2, 1, 2, 1, 2, 2, 2, 0, 1, 2, 2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 2, 0, 1, 2, 1, 2, 1, 2, 1],
      [2, 1, 2, 1, 2, 1, 0, 1, 2, 2, 2, 0, 0, 2, 2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 0, 0, 0, 2, 0, 0, 2, 0, 1, 2, 1, 2, 1, 2, 1],
      [2, 1, 2, 1, 2, 1, 0, 1, 2, 0, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 2, 0, 2, 1, 0, 1, 2, 1, 2, 1, 2],
      [1, 2, 1, 2, 1, 2, 1, 0, 2, 0, 0, 2, 0, 0, 0, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2, 2, 0, 0, 2, 2, 2, 1, 0, 1, 2, 1, 2, 1, 2],
      [1, 2, 1, 2, 1, 2, 1, 0, 2, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2, 2, 1, 0, 2, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2],
      [1, 2, 1, 2, 1, 2, 1, 0, 2, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2],
      [2, 2, 2, 2, 2, 2, 2, 1, 0, 0, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2],
      [1, 0, 1, 2, 1, 2, 1, 0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 2, 2, 0],
      [0, 0, 0, 2, 2, 2, 2, 1, 0, 0, 2, 2, 1, 2, 1, 2, 1, 2, 1, 0],
      [1, 0, 1, 2, 1, 2, 1, 0, 2, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0]
    ]
  }
]

for tile <- tiles do
  Repo.insert!(tile, conflict_target: [:id], on_conflict: {:replace, [:walkable]})
end

for object <- objects do
  Repo.insert!(object, conflict_target: [:id], on_conflict: {:replace, [:walkable]})
end

for %{map: map, tiles: tiles, objects: objects} <- game_maps do
  map =
    Repo.insert!(map, conflict_target: [:name], on_conflict: {:replace, [:name, :width, :height]})

  Repo.delete_all(from m in Maps.MapTile, where: m.game_map_id == ^map.id)
  Repo.delete_all(from m in Maps.MapObject, where: m.game_map_id == ^map.id)

  map_tiles =
    tiles
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {tile_id, x} ->
        %{game_map_id: map.id, tile_id: tile_id, x: x, y: y}
      end)
    end)
    |> List.flatten()

  Repo.insert_all(Maps.MapTile, map_tiles)

  map_objects =
    objects
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {object_id, x} ->
        %{game_map_id: map.id, object_id: object_id, x: x, y: y}
      end)
    end)
    |> List.flatten()
    |> Enum.filter(&(&1.object_id != 0))

  Repo.insert_all(Maps.MapObject, map_objects)
end
