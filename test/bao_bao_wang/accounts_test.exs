defmodule BaoBaoWang.AccountsTest do
  use BaoBaoWang.DataCase

  alias BaoBaoWang.Accounts

  import BaoBaoWang.Factory

  describe "users" do
    alias BaoBaoWang.Accounts.User

    @valid_attrs %{email: Faker.Internet.email(), google_id: "google_id", nickname: "nickname"}
    @update_attrs %{
      email: Faker.Internet.email(),
      google_id: "new_google_id",
      nickname: "new_nickname"
    }
    @invalid_update_attrs %{nickname: 123}

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Accounts.list_users() == [user]
    end

    test "get_user/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user(user.id) == user
    end

    test "create_or_get_user/1 with valid data creates a user if user is not existed" do
      assert {:ok, %User{} = created_user} = Accounts.create_or_get_user(@valid_attrs)
      assert created_user.email == @valid_attrs.email
      assert created_user.google_id == @valid_attrs.google_id
      assert created_user.nickname == nil
    end

    test "create_or_get_user/1 with valid data returns the matched user if user is existed" do
      user = insert(:user)

      assert {:ok, %User{} = created_user} =
               Accounts.create_or_get_user(%{email: user.email, google_id: user.google_id})

      assert created_user.id == user.id
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = updated_user} = Accounts.update_user(user, @update_attrs)
      assert updated_user.email == user.email
      assert updated_user.google_id == user.google_id
      assert updated_user.nickname == @update_attrs.nickname
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_update_attrs)
      assert user == Accounts.get_user(user.id)
    end

    test "increment_user_records/2 increments users record number" do
      for field <- [:wins, :losses, :draws] do
        users = insert_list(2, :user)
        user_ids = Enum.map(users, & &1.id)

        expected_users =
          Enum.map(users, fn user -> %{user | field => Map.get(user, field) + 1} end)

        assert Accounts.increment_user_records(user_ids, field) == expected_users
      end
    end
  end
end
