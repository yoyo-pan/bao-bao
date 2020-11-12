defmodule BaoBaoWang.Repo.Migrations.CreateGameMaps do
  use Ecto.Migration

  def change do
    create table(:game_maps) do
      add :name, :string, null: false
      add :width, :integer, null: false
      add :height, :integer, null: false

      timestamps()
    end

    create unique_index(:game_maps, [:name])
  end
end
