defmodule BaoBaoWang.Repo.Migrations.AddDestroyableToObjects do
  use Ecto.Migration

  def change do
    alter table("objects") do
      add :destroyable, :boolean, null: false, default: false
    end
  end
end
