defmodule BaoBaoWang.Repo.Migrations.CreateTiles do
  use Ecto.Migration

  def change do
    create table(:tiles) do
      add :walkable, :boolean, null: false
    end
  end
end
