defmodule TdDf.Repo.Migrations.AddHierarchiesTable do
  use Ecto.Migration

  def change do
    create table("hierarchies") do
      add :name, :string
      add :description, :string, null: true

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index("hierarchies", :name)

    create table("hierarchy_nodes", primary_key: false) do
      add :hierarchy_id, references("hierarchies", on_delete: :delete_all), primary_key: true
      add :node_id, :bigint, primary_key: true
      add :parent_id, :bigint, null: true
      add :name, :string
      add :description, :string, null: true

      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create unique_index("hierarchy_nodes", [:hierarchy_id, :parent_id, :name],
             name: "distinct_siblings_names"
           )
  end
end
