defmodule BaoBaoWang.Game.GameStateUpdater.MovePlayer do
  @moduledoc false

  alias BaoBaoWang.Game.{GameStateUpdater, Player}

  @behaviour GameStateUpdater

  @valid_directions [:up, :down, :left, :right]
  @moving_speed 250

  @impl true
  def update(state, delta, _time) do
    %{players: players} = state

    Enum.reduce(players, state, fn player, state ->
      update_player(player, state, delta)
    end)
  end

  defp update_player({_, %{is_alive: false}}, state, _), do: state

  defp update_player({player_id, player}, state, delta) do
    %{players: players} = state

    direction =
      if Player.moving?(player),
        do: player.direction,
        else: player.key_down && String.to_existing_atom(player.key_down)

    player = move(player, direction, state, delta)

    %{state | players: Map.put(players, player_id, player)}
  end

  defp move(%Player{} = player, direction, _state, delta)
       when direction in @valid_directions do
    distance = delta / @moving_speed
    {new_x, new_y} = new_position(player, direction)

    %{player | x: new_x, y: new_y, direction: direction} |> move_distance(direction, distance)
  end

  defp move(%Player{} = player, _, _, _) do
    player
  end

  defp new_position(%{x: x, y: y, y_progress: y_progress}, :up)
       when y == y_progress and y - 1 >= 0,
       do: {x, y - 1}

  defp new_position(%{x: x, y: y, y_progress: y_progress}, :down)
       when y == y_progress and y + 1 < 20,
       do: {x, y + 1}

  defp new_position(%{x: x, y: y, x_progress: x_progress}, :left)
       when x == x_progress and x - 1 >= 0,
       do: {x - 1, y}

  defp new_position(%{x: x, y: y, x_progress: x_progress}, :right)
       when x == x_progress and x + 1 < 20,
       do: {x + 1, y}

  defp new_position(%{x: x, y: y}, _), do: {x, y}

  defp move_distance(%{y: y, y_progress: y_progress} = player, :up, distance) do
    new_y_progress = y_progress - distance
    new_y_progress = if new_y_progress < y, do: y * 1.0, else: new_y_progress
    %{player | y_progress: new_y_progress}
  end

  defp move_distance(%{y: y, y_progress: y_progress} = player, :down, distance) do
    new_y_progress = y_progress + distance
    new_y_progress = if new_y_progress > y, do: y * 1.0, else: new_y_progress
    %{player | y_progress: new_y_progress}
  end

  defp move_distance(%{x: x, x_progress: x_progress} = player, :left, distance) do
    new_x_progress = x_progress - distance
    new_x_progress = if new_x_progress < x, do: x * 1.0, else: new_x_progress
    %{player | x_progress: new_x_progress}
  end

  defp move_distance(%{x: x, x_progress: x_progress} = player, :right, distance) do
    new_x_progress = x_progress + distance
    new_x_progress = if new_x_progress > x, do: x * 1.0, else: new_x_progress
    %{player | x_progress: new_x_progress}
  end
end
