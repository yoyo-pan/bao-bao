defmodule BaoBaoWang.Repo.Migrations.CreateObjects do
  use Ecto.Migration

  def change do
    create table(:objects) do
      add :walkable, :boolean, default: false, null: false
    end
  end
end
