defmodule TdDf.Repo.Migrations.AddScopeFieldToTemplates do
  @moduledoc """
  This migration will add a new scope field to the templates
  table
  """
  use Ecto.Migration

  def up do
    alter table(:templates) do
      add(:scope, :string, null: true)
    end
  end

  def down do
    alter table(:templates) do
      remove(:scope)
    end
  end
end
