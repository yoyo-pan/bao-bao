defmodule BaoBaoWang.Repo.Migrations.CreateMapObjects do
  use Ecto.Migration

  def change do
    create table(:map_objects, primary_key: false) do
      add :game_map_id, references(:game_maps, on_delete: :delete_all), primary_key: true
      add :x, :integer, primary_key: true
      add :y, :integer, primary_key: true
      add :object_id, references(:objects, on_delete: :delete_all)
    end

    create index(:map_objects, [:game_map_id])
    create index(:map_objects, [:x])
    create index(:map_objects, [:y])

    create unique_index(:map_objects, [:game_map_id, :x, :y])
  end
end
