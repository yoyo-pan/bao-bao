defmodule BaoBaoWang.Game.GameStateUpdater do
  @moduledoc false

  alias BaoBaoWang.Game.GameState

  @callback update(%GameState{}, integer, integer) :: %GameState{}
end
