defmodule TdDf.Repo.Migrations.AddSubscopeToTemplate do
  use Ecto.Migration

  def change do
    alter table("templates") do
      add :subscope, :string, null: true
    end
  end
end
