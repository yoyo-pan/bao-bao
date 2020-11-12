defmodule BaoBaoWangWeb.Schema.AccountsTypesTest do
  use BaoBaoWangWeb.ConnCase, async: true

  import BaoBaoWang.Factory
  import Mox

  alias BaoBaoWang.UserTokenMock

  setup :verify_on_exit!

  describe "viewer query" do
    @query """
    {
      viewer {
        nickname
        wins
        losses
        draws
      }
    }
    """

    test "returns current user", %{conn: conn} do
      user = insert(:user)
      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "viewer" => %{
                   "nickname" => user.nickname,
                   "wins" => 0,
                   "losses" => 0,
                   "draws" => 0
                 }
               }
             }
    end

    test "returns Unauthenticated error if the authentication failed", %{conn: conn} do
      res = post_query(conn, @query)

      assert %{"data" => %{"viewer" => nil}, "errors" => errors} = res
      assert [%{"code" => 1, "message" => "Unauthenticated"}] = errors
    end
  end

  describe "login mutation" do
    test "creates an user if not existed and returns it with token", %{conn: conn} do
      expect(UserTokenMock, :gen_token, fn _ -> "token" end)

      email = Faker.Internet.email()

      query = """
      mutation {
        login(input: {
          email: "#{email}",
          googleId: "googleId"
        }) {
          result {
            user {
              email
              googleId
              nickname
            }
            token
          }
          successful
        }
      }
      """

      res = post_query(conn, query)

      assert res == %{
               "data" => %{
                 "login" => %{
                   "result" => %{
                     "user" => %{"email" => email, "googleId" => "googleId", "nickname" => nil},
                     "token" => "token"
                   },
                   "successful" => true
                 }
               }
             }
    end

    test "returns error if failed", %{conn: conn} do
      user = insert(:user)

      query = """
      mutation {
        login(input: {
          email: "#{user.email}",
          googleId: "googleId2"
        }) {
          messages {
            field
            message
            template
          }
          successful
        }
      }
      """

      res = post_query(conn, query)

      assert res == %{
               "data" => %{
                 "login" => %{
                   "messages" => [
                     %{
                       "field" => "email",
                       "message" => "has already been taken",
                       "template" => "has already been taken"
                     }
                   ],
                   "successful" => false
                 }
               }
             }
    end
  end

  describe "update_nickname mutation" do
    @query """
    mutation {
      update_nickname(input: {
        nickname: "new nickname"
      }) {
        result {
          nickname
        }
        successful
      }
    }
    """

    test "updates nickname of the current user", %{conn: conn} do
      user = insert(:user)
      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "update_nickname" => %{
                   "result" => %{"nickname" => "new nickname"},
                   "successful" => true
                 }
               }
             }
    end

    test "returns Unauthenticated error if the authentication failed", %{conn: conn} do
      res = post_query(conn, @query)

      assert %{"data" => %{"update_nickname" => nil}, "errors" => errors} = res
      assert [%{"code" => 1, "message" => "Unauthenticated"}] = errors
    end
  end
end
