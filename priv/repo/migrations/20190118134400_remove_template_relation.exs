defmodule TdDf.Repo.Migrations.RemoveTemplateRelation do
  use Ecto.Migration

  def change do
    drop table(:template_relations)
  end
end
