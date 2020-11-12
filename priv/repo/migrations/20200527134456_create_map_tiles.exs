defmodule BaoBaoWang.Repo.Migrations.CreateMapTiles do
  use Ecto.Migration

  def change do
    create table(:map_tiles, primary_key: false) do
      add :game_map_id, references(:game_maps, on_delete: :delete_all), primary_key: true
      add :x, :integer, primary_key: true
      add :y, :integer, primary_key: true
      add :tile_id, references(:tiles, on_delete: :delete_all)
    end

    create index(:map_tiles, [:game_map_id])
    create index(:map_tiles, [:x])
    create index(:map_tiles, [:y])

    create unique_index(:map_tiles, [:game_map_id, :x, :y])
  end
end
