defmodule TdDfWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias Phoenix.ConnTest
  import TdDfWeb.Authentication, only: :functions

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import TdDf.Factory

      alias TdDfWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint TdDfWeb.Endpoint
    end
  end

  @user_name "app-admin"

  setup tags do
    :ok = Sandbox.checkout(TdDf.Repo)

    unless tags[:async] do
      Sandbox.mode(TdDf.Repo, {:shared, self()})
    end

    cond do
      tags[:admin_authenticated] ->
        authenticate_as("admin")

      tags[:service_authenticated] ->
        authenticate_as("service")

      tags[:agent_authenticated] ->
        authenticate_as("agent")

      tags[:user_authenticated] ->
        authenticate_as("user")

      true ->
        {:ok, conn: ConnTest.build_conn()}
    end
  end

  defp authenticate_as(role) do
    @user_name
    |> create_claims(role: role)
    |> create_user_auth_conn()
  end
end
