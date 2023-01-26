defmodule TdDf.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias Ecto.Changeset

  using do
    quote do
      alias TdDf.Repo

      import Assertions
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import TdDf.DataCase
      import TdDf.Factory
    end
  end

  setup tags do
    :ok = Sandbox.checkout(TdDf.Repo)

    unless tags[:async] do
      Sandbox.mode(TdDf.Repo, {:shared, self()})
      # parent = self()
      # case Process.whereis(TdDf.DomainLoader) do
      #   nil -> nil
      #   pid -> Sandbox.allow(TdDf.Repo, parent, pid)
      # end
      nil
    end

    :ok
  end

  @doc ~S"""
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
