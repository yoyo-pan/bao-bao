defmodule BaoBaoWang.Game.GameState do
  @moduledoc false

  defstruct players: %{}, bombs: %{}, objects: %{}, object_info: %{}, last_updated_time: 0

  import Absinthe.Relay.Node, only: [to_global_id: 2]

  alias BaoBaoWang.Game.{CommandHandler, Player}
  alias BaoBaoWang.Game.GameStateUpdater, as: Updater

  @default_positions [
    {2, 0},
    {17, 19},
    {18, 1},
    {1, 18},
    {10, 1},
    {9, 18},
    {6, 8},
    {13, 11}
  ]

  @state_updaters [
    Updater.MovePlayer,
    Updater.BombExplosion
  ]

  def new(params \\ %{}) do
    players = params |> Map.get(:players) |> init_players()
    {objects, object_info} = params |> Map.get(:map_objects) |> init_objects()

    %__MODULE__{players: players, objects: objects, object_info: object_info}
  end

  def update(%__MODULE__{} = state, commands, current_time) do
    commands
    |> Enum.reduce(state, fn command, state ->
      {_, {_, _, command_time}} = command

      state
      |> apply_updaters(command_time)
      |> CommandHandler.apply_command(command)
      |> Map.put(:last_updated_time, command_time)
    end)
    |> apply_updaters(current_time)
    |> Map.put(:last_updated_time, current_time)
  end

  def zip(%__MODULE__{} = state) do
    %{players: players, bombs: bombs, objects: objects} = state

    %{
      "players" => zip_players(players),
      "bombs" => zip_bombs(bombs),
      "objects" => zip_objects(objects)
    }
  end

  defp init_players(nil), do: %{}

  defp init_players(players) do
    players
    |> Enum.with_index()
    |> Enum.map(fn {player_id, index} ->
      {x, y} = Enum.at(@default_positions, index)
      {player_id, %Player{x: x, y: y, x_progress: x * 1.0, y_progress: y * 1.0}}
    end)
    |> Map.new()
  end

  defp init_objects(nil), do: {%{}, %{}}

  defp init_objects(map_objects) do
    objects = map_objects |> Enum.map(&{{&1.x, &1.y}, &1.object.id}) |> Map.new()

    object_info =
      map_objects
      |> Enum.map(fn %{object: object} ->
        {object.id, Map.take(object, [:walkable, :destroyable])}
      end)
      |> Map.new()

    {objects, object_info}
  end

  defp apply_updaters(%__MODULE__{} = state, time) do
    %{last_updated_time: last_updated_time} = state
    delta = time - last_updated_time

    Enum.reduce(@state_updaters, state, fn updater, state ->
      updater.update(state, delta, time)
    end)
  end

  defp zip_players(players) do
    players
    |> Enum.map(fn {id, state} ->
      %{x: x, y: y, direction: direction, bombs: player_bombs, is_alive: is_alive} = state

      {to_global_id("User", id),
       %{
         "x" => x,
         "y" => y,
         "direction" => to_string(direction),
         "bombs" => player_bombs,
         "isAlive" => is_alive
       }}
    end)
    |> Map.new()
  end

  defp zip_bombs(bombs) do
    Enum.map(bombs, fn {{x, y}, _} -> %{"x" => x, "y" => y} end)
  end

  defp zip_objects(objects) do
    Enum.map(objects, fn {{x, y}, id} -> %{"x" => x, "y" => y, "id" => id} end)
  end
end
