defmodule BaoBaoWang.Game.Bomb do
  @moduledoc false

  defstruct [:placed_at, :placed_by, life: 2_000, power: 3]

  def exploded?(%__MODULE__{placed_at: placed_at, life: life}, time) do
    placed_at + life <= time
  end
end
