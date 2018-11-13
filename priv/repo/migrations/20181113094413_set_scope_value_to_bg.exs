defmodule TdDf.Repo.Migrations.SetScopeValueToBg do
  @moduledoc """
  Until now all the templates belonged to the bg service. From now on, templates
  could belong to any other domain, but the existing templates already stored in database
  should have bg as scope
  """
  use Ecto.Migration

  def change do
    execute("update templates set scope = 'bg' where scope is null")
  end
end
