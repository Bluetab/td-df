defmodule TdDf.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table("templates") do
      add :name, :string
      add :content, {:array, :map}
      add :label, :string, null: false
      add :scope, :string, null: true

      timestamps(type: :utc_datetime)
    end

    create unique_index("templates", :name)
  end
end
