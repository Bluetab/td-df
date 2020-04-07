defmodule TdDf.Repo.Migrations.CreateTemplateRelations do
  use Ecto.Migration

  def change do
    create table(:template_relations) do
      add(:id_template, :integer, null: false)
      add(:resource_type, :string, null: false)
      add(:resource_id, :integer, null: false)

      timestamps(type: :utc_datetime)
    end
  end
end
