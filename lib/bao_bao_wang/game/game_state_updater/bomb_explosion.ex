defmodule BaoBaoWang.Game.GameStateUpdater.BombExplosion do
  @moduledoc false

  alias BaoBaoWang.Game.{Bomb, GameStateUpdater}

  @behaviour GameStateUpdater

  @impl true
  def update(state, _delta, time) do
    %{bombs: bombs, players: players} = state

    {exploded_bombs, explosion_area} = calc_explosion(state, time)
    rest_bombs = Map.drop(bombs, Map.keys(exploded_bombs))

    new_players =
      players
      |> restore_player_bombs(exploded_bombs)
      |> update_player_alive(explosion_area)

    %{state | bombs: rest_bombs, players: new_players}
    |> update_objects(explosion_area)
  end

  def calc_explosion(%{bombs: bombs} = state, time) do
    exploded_bombs = Enum.filter(bombs, &Bomb.exploded?(elem(&1, 1), time))
    serial_explosion(exploded_bombs, state, Map.new(exploded_bombs), %{})
  end

  defp serial_explosion([], _, exploded_bombs, whole_explosion_area),
    do: {exploded_bombs, whole_explosion_area}

  defp serial_explosion([exploded_bomb | rest_bombs], state, exploded_bombs, whole_explosion_area) do
    %{bombs: bombs} = state
    explosion_area = explosion_area(exploded_bomb, state)
    in_area_bombs = bombs |> Enum.filter(&Map.get(explosion_area, elem(&1, 0))) |> Map.new()
    be_exploded_bombs = Map.drop(in_area_bombs, Map.keys(exploded_bombs))

    serial_explosion(
      rest_bombs ++ Map.to_list(be_exploded_bombs),
      state,
      Map.merge(exploded_bombs, be_exploded_bombs),
      Map.merge(whole_explosion_area, explosion_area)
    )
  end

  defp explosion_area({position, bomb}, state) do
    %{power: power} = bomb

    [
      explosion_line(state, position, {1, 0}, power),
      explosion_line(state, position, {0, 1}, power),
      explosion_line(state, position, {-1, 0}, power),
      explosion_line(state, position, {0, -1}, power)
    ]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.map(&{&1, true})
    |> Map.new()
  end

  defp explosion_line(_, _, _, _, positions \\ [])
  defp explosion_line(_, _, _, -1, positions), do: positions
  @border [-1, 20]
  defp explosion_line(_, {x, y}, _, _, positions) when x in @border or y in @border, do: positions

  defp explosion_line(state, {x, y}, {dx, dy} = direction, power, positions) do
    %{objects: objects} = state
    new_positions = [{x, y} | positions]

    case Map.get(objects, {x, y}) do
      nil -> explosion_line(state, {x + dx, y + dy}, direction, power - 1, new_positions)
      _ -> new_positions
    end
  end

  defp restore_player_bombs(players, bombs) do
    bombs
    |> Map.values()
    |> Enum.reduce(players, fn %{placed_by: player_id}, players ->
      Map.update!(players, player_id, &Map.put(&1, :bombs, &1.bombs + 1))
    end)
  end

  defp update_player_alive(players, explosion_area) do
    Enum.reduce(players, players, fn {player_id, player}, players ->
      %{x: x, y: y} = player

      if Map.has_key?(explosion_area, {x, y}) do
        Map.update!(players, player_id, &Map.put(&1, :is_alive, false))
      else
        players
      end
    end)
  end

  defp update_objects(state, explosion_area) do
    %{objects: objects, object_info: object_info} = state

    new_objects =
      objects
      |> Enum.reject(fn {position, object_id} ->
        %{destroyable: destroyable} = Map.get(object_info, object_id)
        destroyable and Map.has_key?(explosion_area, position)
      end)
      |> Map.new()

    %{state | objects: new_objects}
  end
end
