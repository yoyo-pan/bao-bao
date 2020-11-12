defmodule BaoBaoWang.Maps.Object do
  @moduledoc false

  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: false}

  schema "objects" do
    field :walkable, :boolean
    field :destroyable, :boolean, default: false
  end
end
