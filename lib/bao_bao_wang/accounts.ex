defmodule BaoBaoWang.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias BaoBaoWang.Repo

  alias BaoBaoWang.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user(id), do: Repo.get(User, id)

  def create_or_get_user(attrs) do
    Repo.all(from u in User, where: u.email == ^attrs.email and u.google_id == ^attrs.google_id)
    |> case do
      [] ->
        %User{}
        |> User.create_changeset(attrs)
        |> Repo.insert()

      [user] ->
        {:ok, user}
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def increment_user_records(ids, field) when field in [:wins, :losses, :draws] do
    users_query = from(u in User, where: u.id in ^ids)
    Repo.update_all(users_query, inc: [{field, 1}])
    Repo.all(users_query)
  end

  def data do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(queryable, _params), do: queryable
end
