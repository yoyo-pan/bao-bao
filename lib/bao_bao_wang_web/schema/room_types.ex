defmodule BaoBaoWangWeb.Schema.RoomTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import BaoBaoWangWeb.Schema.Util
  import AbsintheErrorPayload.Payload, except: [build_payload: 2]

  alias Absinthe.Relay.Node.ParseIDs
  alias BaoBaoWangWeb.Resolvers.Room

  node object(:room_player) do
    field :user, non_null(:user)
    field :is_ready, non_null(:boolean)
  end

  node object(:room) do
    field :id_number, non_null(:integer), resolve: &Room.room_id_number/3
    field :host, :user, resolve: &Room.room_host/3
    field :players, non_null(list_of(non_null(:room_player))), resolve: &Room.room_players/3
  end

  payload_object(:room_payload, :room)

  object(:room_queries) do
    field :room, non_null(:room) do
      arg(:id, non_null(:integer))

      resolve(&Room.room/2)
    end

    field :rooms, non_null(list_of(non_null(:room))), resolve: &Room.rooms/2
  end

  object(:room_mutations) do
    field :create_room, non_null(:room_payload) do
      resolve(&Room.create_room/3)
      middleware(&build_payload/2)
    end

    field :join_room, non_null(:room_payload) do
      arg(:room_id, non_null(:integer))

      resolve(&Room.join_room/3)
      middleware(&build_payload/2)
    end

    field :leave_room, non_null(:room_payload) do
      resolve(&Room.leave_room/3)
      middleware(&build_payload/2)
    end

    field :kick_player, non_null(:room_payload) do
      arg(:user_id, non_null(:id))

      middleware(ParseIDs, user_id: :user)
      resolve(&Room.kick_player/3)
      middleware(&build_payload/2)
    end

    field :ready, non_null(:room_payload) do
      resolve(&Room.ready/3)
      middleware(&build_payload/2)
    end

    field :unready, non_null(:room_payload) do
      resolve(&Room.unready/3)
      middleware(&build_payload/2)
    end
  end

  object(:room_subscriptions) do
    field :room_updated, non_null(:room) do
      config(fn _, %{context: %{current_user: current_user}} ->
        case BaoBaoWang.Room.find_user_room(current_user.id) do
          {:ok, room} -> {:ok, topic: "room:#{room.id}:update"}
          _ -> {:error, :user_is_not_joined}
        end
      end)

      trigger(:join_room, topic: &room_update_topic/1)
      trigger(:leave_room, topic: &room_update_topic/1)
      trigger(:kick_player, topic: &room_update_topic/1)
      trigger(:ready, topic: &room_update_topic/1)
      trigger(:unready, topic: &room_update_topic/1)

      resolve(fn %{result: room}, _, _ -> {:ok, room} end)
    end
  end

  defp room_update_topic(%{result: %BaoBaoWang.Room{} = room}), do: "room:#{room.id}:update"
  defp room_update_topic(_), do: nil
end
