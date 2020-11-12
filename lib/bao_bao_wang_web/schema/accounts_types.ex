defmodule BaoBaoWangWeb.Schema.AccountsTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import BaoBaoWangWeb.Schema.Util
  import AbsintheErrorPayload.Payload, except: [build_payload: 2]
  import Absinthe.Relay.Node, only: [to_global_id: 2]

  alias BaoBaoWangWeb.Resolvers.Accounts

  node object(:viewer) do
    field :user_id, non_null(:id),
      resolve: fn %{id: user_id}, _, _ ->
        {:ok, to_global_id("User", user_id)}
      end

    field :nickname, :string
    field :wins, non_null(:integer)
    field :losses, non_null(:integer)
    field :google_id, non_null(:string)
    field :draws, non_null(:integer)
  end

  node object(:user) do
    field :email, non_null(:string)
    field :google_id, non_null(:string)
    field :nickname, :string
  end

  input_object(:login_input) do
    field :email, non_null(:string)
    field :google_id, non_null(:string)
  end

  object(:login_result) do
    field :user, non_null(:user)
    field :token, non_null(:string)
  end

  payload_object(:login_payload, :login_result)

  input_object(:update_nickname_input) do
    field :nickname, non_null(:string)
  end

  payload_object(:viewer_payload, :viewer)

  object(:accounts_queries) do
    field :viewer, :viewer do
      resolve(&Accounts.viewer/2)
    end
  end

  object(:accounts_mutations) do
    field :login, :login_payload do
      arg(:input, non_null(:login_input))

      resolve(&Accounts.login/3)
      middleware(&build_payload/2)
    end

    field :update_nickname, :viewer_payload do
      arg(:input, non_null(:update_nickname_input))

      resolve(&Accounts.update_nickname/3)
      middleware(&build_payload/2)
    end
  end
end
