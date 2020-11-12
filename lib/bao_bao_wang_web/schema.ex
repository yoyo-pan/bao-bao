defmodule BaoBaoWangWeb.Schema do
  @moduledoc false

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias BaoBaoWang.Accounts
  alias BaoBaoWangWeb.Schema.Middleware.Auth

  @auth_fields [
    :viewer,
    :update_nickname,
    :create_room,
    :join_room,
    :leave_room,
    :kick_player
  ]

  import_types(AbsintheErrorPayload.ValidationMessageTypes)
  import_types(__MODULE__.AccountsTypes)
  import_types(__MODULE__.MapsTypes)
  import_types(__MODULE__.RoomTypes)

  node interface do
    resolve_type(fn
      _, _ ->
        nil
    end)
  end

  query do
    node field do
      resolve(fn
        _, _ ->
          {:error, "Unknown node"}
      end)
    end

    import_fields(:accounts_queries)
    import_fields(:maps_queries)
    import_fields(:room_queries)
  end

  mutation do
    import_fields(:accounts_mutations)
    import_fields(:room_mutations)
  end

  subscription do
    import_fields(:room_subscriptions)
  end

  def middleware(middleware, %{identifier: identifier}, _) when identifier in @auth_fields do
    [Auth | middleware]
  end

  def middleware(middleware, _, _) do
    middleware
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Accounts, Accounts.data())

    Map.put(ctx, :loader, loader)
  end
end
