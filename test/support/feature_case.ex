defmodule TdDfWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by
  feature tests.

  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      import TdDfWeb.Router.Helpers
      @endpoint TdDfWeb.Endpoint
    end
  end

  setup tags do
    :ok = Sandbox.checkout(TdDf.Repo)
    unless tags[:async] do
      Sandbox.mode(TdDf.Repo, {:shared, self()})
    end
    :ok
  end
end
