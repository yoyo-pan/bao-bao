defmodule BaoBaoWangWeb.GameChannel do
  @moduledoc false

  use Phoenix.Channel

  alias BaoBaoWang.{Game, Room}
  alias BaoBaoWang.Game.GameState

  @impl true
  def join(topic, _message, socket) do
    ["game", room_id] = String.split(topic, ":")
    room_id = String.to_integer(room_id)
    %{assigns: %{current_user: current_user}} = socket

    case Room.find_user_room(current_user.id) do
      {:ok, %{id: ^room_id}} ->
        {:ok, socket}

      _ ->
        {:error, %{reason: "not in the room"}}
    end
  end

  @impl true
  def handle_in("start_game", _params, socket) do
    %{assigns: %{current_user: %{id: current_user_id}}} = socket

    with {:ok, %Room{id: room_id, host_id: ^current_user_id}} <-
           Room.find_user_room(current_user_id),
         {:ok, %{game_pid: game_pid}} <- Room.start_game(room_id) do
      %{state: state} = Game.get(game_pid)

      broadcast!(socket, "start_game", %{state: GameState.zip(state)})

      {:reply, :ok, socket}
    else
      _ -> {:reply, :error, socket}
    end
  end

  @impl true
  def handle_in("loaded", _params, socket) do
    %{assigns: %{current_user: %{id: current_user_id}}} = socket

    with {:ok, %Room{game_pid: game_pid}} when not is_nil(game_pid) <-
           Room.find_user_room(current_user_id),
         {:ok, _} <- Game.load_player(game_pid, current_user_id),
         true <- Game.ready_to_start?(game_pid),
         {:ok, _} <- Game.start(game_pid) do
      %{start_time: start_time, state: state} = Game.get(game_pid)

      broadcast!(socket, "start_timer", %{time: start_time, state: GameState.zip(state)})
    end

    {:noreply, socket}
  end

  @impl true
  def handle_in("cmd", %{"name" => name, "payload" => payload}, socket) do
    %{assigns: %{current_user: %{id: current_user_id}}} = socket
    command_name = String.to_existing_atom(name)
    current_time = System.os_time(:millisecond)

    with {:ok, %{game_pid: game_pid}} when game_pid != nil <- Room.find_user_room(current_user_id) do
      Game.push_command(game_pid, current_user_id, {command_name, payload, current_time})
    end

    {:noreply, socket}
  end
end
