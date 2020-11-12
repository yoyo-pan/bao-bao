defmodule BaoBaoWang.Maps do
  @moduledoc """
  The Maps context.
  """

  import Ecto.Query, warn: false
  alias BaoBaoWang.Repo

  alias BaoBaoWang.Maps.GameMap

  def get_game_map(id), do: Repo.get(GameMap, id)
end
