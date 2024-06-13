defmodule TdDf.Repo.Migrations.InsertMetadataInFieldsDefaultValues do
  use Ecto.Migration

  import Ecto.Query

  alias TdDf.Repo
  alias TdDf.Templates

  def up, do: migrate(:up)

  # def down, do: migrate(:down)
  def down, do: migrate(:down)

  defp migrate(dir) do
    Templates.list_templates()
    |> Enum.map(&process_group(&1, dir))
  end

  defp process_group(%{id: id, content: groups}, migration_dir) do
    migrated_groups =
      groups
      |> Enum.map(&migrate_default_value_metadata(&1, migration_dir))

    do_update(id, migrated_groups)
  end

  defp migrate_default_value_metadata(%{"fields" => fields} = group, :up) do
    field_with_default_meta =
      fields
      |> Enum.map(fn
        %{"default" => default} = field ->
          Map.put(field, "default", %{"value" => default, "origin" => "default"})

        field ->
          field
      end)

    Map.put(group, "fields", field_with_default_meta)
  end

  defp migrate_default_value_metadata(%{"fields" => fields} = group, :down) do
    field_without_default_meta =
      fields
      |> Enum.map(fn
        %{"default" => %{"value" => default}} = field ->
          Map.put(field, "default", default)

        field ->
          field
      end)

    Map.put(group, "fields", field_without_default_meta)
  end

  defp do_update(id, content) do
    from(t in "templates")
    |> where([t], t.id == ^id)
    |> update([t], set: [content: ^content])
    |> Repo.update_all([])
  end
end
