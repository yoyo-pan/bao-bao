defmodule BaoBaoWang.Game.Player do
  @moduledoc false

  defstruct [
    :x,
    :y,
    :x_progress,
    :y_progress,
    :key_down,
    direction: :down,
    bombs: 3,
    is_alive: true
  ]

  def moving?(%__MODULE__{} = player) do
    %{x: x, y: y, x_progress: x_progress, y_progress: y_progress} = player
    x != x_progress or y != y_progress
  end
end
