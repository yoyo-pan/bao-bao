defmodule BaoBaoWang.Maps.Tile do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: false}

  schema "tiles" do
    field :walkable, :boolean
  end
end
