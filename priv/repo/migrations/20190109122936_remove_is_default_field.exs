defmodule TdDf.Repo.Migrations.RemoveIsDefaultField do
  use Ecto.Migration

  def up do
    alter table(:templates) do
      remove :is_default
    end
  end

  def down do
    alter table(:templates) do
      add :is_default, :boolean, default: false, null: false
    end
  end
end
