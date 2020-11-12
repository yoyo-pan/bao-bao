defmodule BaoBaoWang.Room do
  @moduledoc false

  defstruct [:id, :game_pid, :host_id, :map_id, players: []]

  use GenServer

  alias BaoBaoWang.Game
  alias BaoBaoWang.Room.RoomPlayer

  @max_players 8

  @impl true
  def init(_args) do
    {:ok, %{rooms: %{}, player_room_map: %{}}}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def reset do
    GenServer.cast(__MODULE__, :reset)
  end

  def create(host_id) do
    GenServer.call(__MODULE__, {:create, host_id})
  end

  def get(room_id) do
    GenServer.call(__MODULE__, {:get, room_id})
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  def join(user_id, room_id) do
    GenServer.call(__MODULE__, {:join, room_id, user_id})
  end

  def leave(user_id, room_id) do
    GenServer.call(__MODULE__, {:leave, room_id, user_id})
  end

  def close(room_id) do
    GenServer.call(__MODULE__, {:close, room_id})
  end

  def find_user_room(user_id) do
    GenServer.call(__MODULE__, {:find_user_room, user_id})
  end

  def start_game(room_id) do
    GenServer.call(__MODULE__, {:start_game, room_id})
  end

  def ready(user_id, room_id) do
    GenServer.call(__MODULE__, {:set_ready, room_id, user_id, true})
  end

  def unready(user_id, room_id) do
    GenServer.call(__MODULE__, {:set_ready, room_id, user_id, false})
  end

  @impl true
  def handle_cast(:reset, _state) do
    {:noreply, %{rooms: %{}, player_room_map: %{}}}
  end

  @impl true
  def handle_call({:create, host_id}, _from, state) do
    %{rooms: rooms, player_room_map: player_room_map} = state

    if user_joined?(player_room_map, host_id) do
      {:reply, {:error, :user_is_joined}, state}
    else
      new_room = %__MODULE__{
        id: gen_id(rooms),
        players: [%RoomPlayer{id: host_id}],
        host_id: host_id,
        map_id: 1
      }

      new_state = %{
        state
        | rooms: Map.put(rooms, new_room.id, new_room),
          player_room_map: Map.put(player_room_map, host_id, new_room.id)
      }

      {:reply, {:ok, new_room}, new_state}
    end
  end

  @impl true
  def handle_call({:get, room_id}, _from, state) do
    %{rooms: rooms} = state

    case Map.get(rooms, room_id) do
      nil -> {:reply, {:error, :room_is_not_found}, state}
      room -> {:reply, {:ok, room}, state}
    end
  end

  @impl true
  def handle_call(:list, _from, state) do
    %{rooms: rooms} = state

    sorted_rooms =
      rooms
      |> Map.values()
      |> Enum.sort_by(& &1.id)

    {:reply, {:ok, sorted_rooms}, state}
  end

  @impl true
  def handle_call({:join, room_id, user_id}, _from, state) do
    %{rooms: rooms, player_room_map: player_room_map} = state

    case Map.get(rooms, room_id) do
      nil ->
        {:reply, {:error, :room_is_not_found}, state}

      %{players: players} when length(players) >= @max_players ->
        {:reply, {:error, :room_is_full}, state}

      %{players: players, id: room_id} = room ->
        cond do
          user_joined?(player_room_map, user_id) ->
            {:reply, {:error, :user_is_joined}, state}

          game_started?(room) ->
            {:reply, {:error, :game_is_started}, state}

          true ->
            new_room = %{room | players: [%RoomPlayer{id: user_id} | players]}

            {:reply, {:ok, new_room},
             %{
               state
               | rooms: Map.put(rooms, room_id, new_room),
                 player_room_map: Map.put(player_room_map, user_id, room_id)
             }}
        end
    end
  end

  @impl true
  def handle_call({:leave, room_id, user_id}, _from, state) do
    %{rooms: rooms, player_room_map: player_room_map} = state

    case Map.get(rooms, room_id) do
      nil ->
        {:reply, {:error, :room_is_not_found}, state}

      %{players: [_player]} = room ->
        new_room = %{room | players: [], host_id: nil}

        {:reply, {:ok, new_room},
         %{
           state
           | rooms: Map.delete(rooms, room_id),
             player_room_map: Map.delete(player_room_map, user_id)
         }}

      %{players: players} = room ->
        new_players = Enum.reject(players, &(&1.id == user_id))
        new_host = List.last(new_players)
        new_room = %{room | players: new_players, host_id: new_host && new_host.id}

        {:reply, {:ok, new_room},
         %{
           state
           | rooms: Map.put(rooms, room_id, new_room),
             player_room_map: Map.delete(player_room_map, user_id)
         }}
    end
  end

  def handle_call({:close, room_id}, _from, state) do
    %{rooms: rooms, player_room_map: player_room_map} = state

    case Map.get(rooms, room_id) do
      nil ->
        {:reply, {:error, :room_is_not_found}, state}

      %{players: players} = room ->
        new_player_room_map =
          player_room_map
          |> Enum.reject(fn {player_id, _} -> Enum.any?(players, &(&1.id == player_id)) end)
          |> Enum.into(%{})

        {:reply, {:ok, room},
         %{state | rooms: Map.delete(rooms, room_id), player_room_map: new_player_room_map}}
    end
  end

  def handle_call({:find_user_room, user_id}, _from, state) do
    %{rooms: rooms, player_room_map: player_room_map} = state

    result =
      case Map.get(player_room_map, user_id) do
        nil -> {:error, :room_is_not_found}
        room_id -> {:ok, Map.get(rooms, room_id)}
      end

    {:reply, result, state}
  end

  def handle_call({:start_game, room_id}, _from, state) do
    %{rooms: rooms} = state

    case Map.get(rooms, room_id) do
      nil ->
        {:reply, {:error, :room_is_not_found}, state}

      %{players: players} = room ->
        cond do
          game_started?(room) ->
            {:reply, {:error, :game_is_started}, state}

          length(players) < 2 ->
            {:reply, {:error, :too_few_players}, state}

          not players_ready?(room) ->
            {:reply, {:error, :player_is_not_ready}, state}

          true ->
            {:ok, game_pid} = Game.start_link(room)
            new_room = %{room | game_pid: game_pid}

            {:reply, {:ok, new_room}, %{state | rooms: Map.put(rooms, room_id, new_room)}}
        end
    end
  end

  def handle_call({:set_ready, room_id, user_id, is_ready}, _from, state) do
    %{rooms: rooms} = state

    case Map.get(rooms, room_id) do
      %{players: players} = room ->
        new_players =
          Enum.map(players, fn
            %{id: ^user_id} = player -> %{player | is_ready: is_ready}
            player -> player
          end)

        new_room = %{room | players: new_players}

        {:reply, {:ok, new_room}, %{state | rooms: Map.put(rooms, room_id, new_room)}}

      _ ->
        {:reply, {:error, :room_is_not_found}, state}
    end
  end

  defp gen_id(rooms) do
    {last_id, _} =
      rooms
      |> Map.keys()
      |> Enum.sort()
      |> List.insert_at(0, 0)
      |> Enum.with_index()
      |> Enum.filter(fn {a, b} -> a == b end)
      |> List.last()

    last_id + 1
  end

  defp user_joined?(player_room_map, user_id), do: Map.has_key?(player_room_map, user_id)

  defp game_started?(%{game_pid: nil}), do: false

  defp game_started?(%{game_pid: game_pid}) do
    %{status: status} = Game.get(game_pid)
    status != :finished
  end

  defp players_ready?(%{players: players, host_id: host_id}) do
    Enum.all?(players, &(&1.is_ready or &1.id == host_id))
  end
end
