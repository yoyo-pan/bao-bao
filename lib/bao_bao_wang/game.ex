defmodule BaoBaoWang.Game do
  @moduledoc false

  defstruct [
    :ticker,
    :command_queue,
    :room,
    :start_time,
    :state,
    status: :initialized,
    loaded_players: []
  ]

  use GenServer

  import Absinthe.Relay.Node, only: [to_global_id: 2]

  alias BaoBaoWang.{Accounts, Maps, Repo}
  alias BaoBaoWang.Game.{CommandQueue, GameState}
  alias BaoBaoWang.{Room, Ticker}
  alias BaoBaoWangWeb.Endpoint

  @behaviour Ticker.TickerObserver

  @impl true
  def init(%Room{players: players, map_id: map_id} = room) do
    map = map_id |> Maps.get_game_map() |> Repo.preload([map_objects: [:object]])
    state = GameState.new(%{players: Enum.map(players, & &1.id), map_objects: map.map_objects})
    game = %__MODULE__{room: room, state: state}
    {:ok, game}
  end

  def start_link(%Room{} = room) do
    GenServer.start_link(__MODULE__, room)
  end

  def load_player(game_pid, user_id) do
    GenServer.call(game_pid, {:load_player, user_id})
  end

  def ready_to_start?(game_pid) do
    GenServer.call(game_pid, :ready_to_start?)
  end

  def start(game_pid) do
    GenServer.call(game_pid, :start)
  end

  def stop(game_pid) do
    GenServer.call(game_pid, :stop)
  end

  @impl true
  def tick(game_pid, delta, time) do
    GenServer.cast(game_pid, {:tick, delta, time})
  end

  def get(game_pid) do
    GenServer.call(game_pid, :get)
  end

  def push_command(game_pid, user_id, command) do
    GenServer.cast(game_pid, {:push_command, user_id, command})
  end

  @impl true
  def handle_call({:load_player, user_id}, _from, game) do
    %{room: room, loaded_players: loaded_players} = game

    new_game =
      if Enum.any?(room.players, &(&1.id == user_id)) and
           not Enum.member?(loaded_players, user_id) do
        %{game | loaded_players: [user_id | loaded_players]}
      else
        game
      end

    {:reply, {:ok, new_game}, new_game}
  end

  @impl true
  def handle_call(:start, _from, game) do
    %{state: state} = game
    ticker_interval = Application.get_env(:bao_bao_wang, :game_ticker_interval)
    current_time = System.os_time(:millisecond)
    {:ok, ticker_pid} = Ticker.start({__MODULE__, self()}, ticker_interval)
    {:ok, command_queue_pid} = CommandQueue.start_link()

    game = %{
      game
      | ticker: ticker_pid,
        command_queue: command_queue_pid,
        start_time: current_time,
        status: :started,
        state: %{state | last_updated_time: current_time}
    }

    {:reply, {:ok, game}, game}
  end

  @impl true
  def handle_call(:stop, _from, game) do
    current_time = System.os_time(:millisecond)
    new_game = finish_game(game, current_time)

    {:reply, {:ok, new_game}, new_game}
  end

  @impl true
  def handle_call(:get, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_call(:ready_to_start?, _from, %{status: :initialized} = game) do
    %{room: room, loaded_players: loaded_players} = game
    is_ready = length(room.players) == length(loaded_players)

    {:reply, is_ready, game}
  end

  @impl true
  def handle_call(:ready_to_start?, _from, game) do
    {:reply, false, game}
  end

  @impl true
  def handle_cast({:tick, _delta, time}, game) do
    %{command_queue: command_queue, state: state, status: status} = game

    cond do
      status == :finished ->
        {:noreply, game}

      game_over?(state) ->
        broadcast_state(game, time)
        new_game = finish_game(game, time)
        {:noreply, new_game}

      true ->
        commands = CommandQueue.pull_commands(command_queue, time)
        new_state = GameState.update(state, commands, time)

        broadcast_state(game, time)

        {:noreply, %{game | state: new_state}}
    end
  end

  @impl true
  def handle_cast({:push_command, _, _}, %{command_queue: nil} = game) do
    {:noreply, game}
  end

  @impl true
  def handle_cast({:push_command, user_id, command}, game) do
    %{command_queue: command_queue} = game
    CommandQueue.push(command_queue, {user_id, command})

    {:noreply, game}
  end

  defp game_over?(%{players: players}) do
    alives =
      players
      |> Enum.filter(fn {_, player} -> player.is_alive end)
      |> Enum.count()

    alives < 2
  end

  defp finish_game(%__MODULE__{} = game, time) do
    %{ticker: ticker, room: room, state: state} = game
    %{players: players} = state

    Ticker.stop(ticker)

    winners =
      players
      |> Enum.filter(fn {_, player} -> player.is_alive end)
      |> Enum.map(&elem(&1, 0))

    losers =
      players
      |> Map.drop(winners)
      |> Enum.map(&elem(&1, 0))

    users = update_game_record(winners, losers) |> Enum.map(&{&1.id, &1}) |> Map.new()

    Endpoint.broadcast!("game:#{room.id}", "finish", %{
      time: time,
      winners: users |> Map.take(winners) |> user_results(),
      losers: users |> Map.take(losers) |> user_results()
    })

    %{game | ticker: nil, status: :finished}
  end

  defp update_game_record([_] = winners, losers) do
    Accounts.increment_user_records(winners, :wins) ++
      Accounts.increment_user_records(losers, :losses)
  end

  defp update_game_record(winners, losers) do
    Accounts.increment_user_records(winners ++ losers, :draws)
  end

  defp user_results(users) do
    users
    |> Enum.map(fn {user_id, user} ->
      %{nickname: nickname, wins: wins, losses: losses, draws: draws} = user

      {
        to_global_id("User", user_id),
        %{"nickname" => nickname, "wins" => wins, "losses" => losses, "draws" => draws}
      }
    end)
    |> Map.new()
  end

  defp broadcast_state(%__MODULE__{room: room, state: state}, time) do
    zipped_state = GameState.zip(state)
    Endpoint.broadcast!("game:#{room.id}", "state", %{time: time, state: zipped_state})
  end
end
