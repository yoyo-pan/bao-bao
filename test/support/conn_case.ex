defmodule BaoBaoWangWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use BaoBaoWangWeb.ConnCase, async: true`, although
  this option is not recommendded for other databases.
  """

  use ExUnit.CaseTemplate

  alias BaoBaoWang.Repo
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      import Mox

      alias BaoBaoWang.UserTokenMock
      alias BaoBaoWangWeb.{Endpoint, Errors}
      alias BaoBaoWangWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint BaoBaoWangWeb.Endpoint

      def post_query(conn, query, opts \\ []) do
        current_user = Keyword.get(opts, :current_user)

        conn
        |> put_current_user(current_user)
        |> post("/api", %{query: query})
        |> json_response(200)
      end

      defp put_current_user(conn, nil), do: conn

      defp put_current_user(conn, user) do
        expect(UserTokenMock, :from_token, fn _ -> user.id end)
        put_req_header(conn, "authorization", "Bearer token")
      end
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
