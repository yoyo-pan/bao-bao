defmodule BaoBaoWang.Repo.Migrations.UpdateUsersRecord do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :draws, :integer, null: false, default: 0
    end
  end
end
