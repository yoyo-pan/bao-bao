defmodule BaoBaoWang.Ticker.TickerObserver do
  @moduledoc false

  @callback tick(pid, integer, integer) :: :ok
end
