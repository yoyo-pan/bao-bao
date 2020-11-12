defmodule BaoBaoWang.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: BaoBaoWang.Repo

  alias BaoBaoWang.{Accounts, Maps}

  def user_factory do
    %Accounts.User{
      email: Faker.Internet.email(),
      google_id: Faker.String.base64(),
      nickname: "nickname"
    }
  end

  def game_map_factory do
    %Maps.GameMap{
      name: "Village 10",
      width: 2,
      height: 2
    }
  end

  def tile_factory do
    %Maps.Tile{
      id: 1,
      walkable: true
    }
  end

  def map_tile_factory do
    %Maps.MapTile{}
  end

  def with_map_tiles(%Maps.GameMap{} = game_map) do
    tile1 = insert(:tile, id: 1)
    tile2 = insert(:tile, id: 2)
    insert(:map_tile, game_map: game_map, tile: tile1, x: 0, y: 0)
    insert(:map_tile, game_map: game_map, tile: tile1, x: 0, y: 1)
    insert(:map_tile, game_map: game_map, tile: tile2, x: 1, y: 0)
    insert(:map_tile, game_map: game_map, tile: tile1, x: 1, y: 1)
    game_map
  end

  def object_factory do
    %Maps.Object{
      id: 1,
      walkable: true
    }
  end

  def map_object_factory do
    %Maps.MapObject{}
  end

  def with_map_objects(%Maps.GameMap{} = game_map) do
    object = insert(:object)
    insert(:map_object, game_map: game_map, object: object, x: 0, y: 0)
    insert(:map_object, game_map: game_map, object: object, x: 0, y: 1)
    game_map
  end
end
