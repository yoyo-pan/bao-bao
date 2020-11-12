defmodule BaoBaoWang.Ticker do
  @moduledoc false

  def start({_module, _pid} = observer, interval) do
    init_time = System.os_time(:millisecond)
    ticker_pid = spawn_link(__MODULE__, :loop, [observer, interval, init_time])

    {:ok, ticker_pid}
  end

  def stop(ticker_pid) do
    send(ticker_pid, :stop)
  end

  def loop({observer_module, observer_pid} = observer, interval, last_time) do
    receive do
      :stop ->
        :ok
    after
      interval ->
        current_time = System.os_time(:millisecond)
        delta = current_time - last_time

        observer_module.tick(observer_pid, delta, current_time)
        loop(observer, interval, current_time)
    end
  end
end
