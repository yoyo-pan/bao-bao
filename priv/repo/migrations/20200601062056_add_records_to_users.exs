defmodule BaoBaoWang.Repo.Migrations.AddRecordsToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :wins, :integer, null: false, default: 0
      add :losses, :integer, null: false, default: 0
    end
  end
end
