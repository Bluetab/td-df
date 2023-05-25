defmodule TdDf.Repo.Migrations.UpdateHierarchyNodeNamesToAvoidPathConflicts do
  use Ecto.Migration

  def up do
    execute("UPDATE hierarchy_nodes
            SET name = replace(name, '/', '\')")
  end

  def down do
    execute("UPDATE hierarchy_nodes
            SET name = replace(name, '\', '/')")
  end
end
