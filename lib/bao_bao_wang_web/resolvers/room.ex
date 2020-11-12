defmodule BaoBaoWangWeb.Resolvers.Room do
  @moduledoc false

  import Absinthe.Resolution.Helpers

  alias BaoBaoWang.{Accounts, Room}

  def room(%{id: room_id}, _) do
    Room.get(room_id)
  end

  def rooms(_, _) do
    Room.list()
  end

  def room_id_number(%Room{id: room_id}, _, _), do: {:ok, room_id}

  def room_host(%Room{host_id: host_id}, _, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(Accounts, Accounts.User, host_id)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, Accounts, Accounts.User, host_id)}
    end)
  end

  def room_players(%Room{players: players}, _, %{context: %{loader: loader}}) do
    player_ids = Enum.map(players, & &1.id)

    loader
    |> Dataloader.load_many(Accounts, Accounts.User, player_ids)
    |> on_load(fn loader ->
      room_players =
        loader
        |> Dataloader.get_many(Accounts, Accounts.User, player_ids)
        |> Enum.zip(players)
        |> Enum.map(fn {user, %{is_ready: is_ready}} ->
          %{id: user.id, user: user, is_ready: is_ready}
        end)

      {:ok, room_players}
    end)
  end

  def create_room(_, _, %{context: %{current_user: current_user}}) do
    Room.create(current_user.id)
  end

  def join_room(_, %{room_id: room_id}, %{context: %{current_user: current_user}}) do
    Room.join(current_user.id, room_id)
  end

  def leave_room(_, _, %{context: %{current_user: current_user}}) do
    case Room.find_user_room(current_user.id) do
      {:ok, room} -> Room.leave(current_user.id, room.id)
      {:error, _} -> {:error, :user_is_not_joined}
    end
  end

  def kick_player(_, %{user_id: user_id}, %{context: %{current_user: %{id: current_user_id}}}) do
    guest_user_id = String.to_integer(user_id)

    case Room.find_user_room(current_user_id) do
      {:ok, %{host_id: ^current_user_id}} when guest_user_id == current_user_id ->
        {:error, :cannot_kick_yourself}

      {:ok, %{id: room_id, host_id: ^current_user_id}} ->
        Room.leave(guest_user_id, room_id)

      {:ok, _} ->
        {:error, :user_is_not_host}

      {:error, _} ->
        {:error, :user_is_not_joined}
    end
  end

  def ready(_, _, %{context: %{current_user: current_user}}) do
    case Room.find_user_room(current_user.id) do
      {:ok, room} -> Room.ready(current_user.id, room.id)
      {:error, _} -> {:error, :user_is_not_joined}
    end
  end

  def unready(_, _, %{context: %{current_user: current_user}}) do
    case Room.find_user_room(current_user.id) do
      {:ok, room} -> Room.unready(current_user.id, room.id)
      {:error, _} -> {:error, :user_is_not_joined}
    end
  end
end
