defmodule BaoBaoWang.Game.CommandHandler do
  @moduledoc false

  alias BaoBaoWang.Game.{Bomb, GameState}

  def apply_command(%GameState{} = state, {player_id, command}) do
    %{players: players, last_updated_time: last_updated_time} = state
    {_, _, command_time} = command
    delta = command_time - last_updated_time
    player = Map.get(players, player_id)

    if player do
      handle_command(command, %{
        state: state,
        delta: delta,
        player_id: player_id,
        player: player
      })
    else
      state
    end
  end

  defp handle_command({:key_down, key, _time}, params) do
    %{state: state, player_id: player_id, player: player} = params
    %{players: players} = state

    %{state | players: Map.put(players, player_id, %{player | key_down: key})}
  end

  defp handle_command({:key_up, key, _time}, %{player: %{key_down: key}} = params) do
    %{state: state, player_id: player_id, player: player} = params
    %{players: players} = state

    %{state | players: Map.put(players, player_id, %{player | key_down: nil})}
  end

  defp handle_command({:place_bomb, nil, time}, params) do
    %{state: state, player_id: player_id, player: player} = params
    %{players: players, bombs: bombs} = state
    %{x: x, y: y, bombs: player_bombs} = player

    cond do
      not player.is_alive ->
        state

      player_bombs == 0 ->
        state

      Map.get(bombs, {x, y}) != nil ->
        state

      true ->
        player = %{player | bombs: player_bombs - 1}
        bomb = %Bomb{placed_at: time, placed_by: player_id}

        %{
          state
          | players: Map.put(players, player_id, player),
            bombs: Map.put(bombs, {x, y}, bomb)
        }
    end
  end

  defp handle_command(_, %{state: state}) do
    state
  end
end
