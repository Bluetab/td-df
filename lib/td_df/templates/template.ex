defmodule TdDf.Templates.Template do
  @moduledoc "Ecto Schema module for templates"

  use Ecto.Schema

  import Ecto.Changeset

  alias TdDf.Templates

  @validations [
    :repeated_group_names,
    :repeated_names,
    :name_and_types,
    :subscribable,
    :group_names,
    :field_names,
    :field_label,
    :widget,
    :type,
    :cardinality,
    :user_roles,
    :group_roles,
    :type_hierarchy,
    :type_table,
    :dropdown_string_value,
    :depending_domain,
    :depending_domain_list,
    :depending_field,
    :fixed_list,
    :key_value_list,
    :conditional_visibility,
    :mandatory_depending
  ]

  schema "templates" do
    field(:content, {:array, :map})
    field(:label, :string)
    field(:name, :string)
    field(:scope, :string)
    field(:subscope, :string)

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = struct, params) do
    do_changeset(struct, params)
  end

  def update_changeset(%__MODULE__{} = struct, %{} = params) do
    do_changeset(struct, params, [:label, :content, :scope, :subscope])
  end

  defp do_changeset(
         %__MODULE__{} = struct,
         %{} = params,
         attrs \\ [:label, :name, :content, :scope, :subscope]
       ) do
    changeset =
      struct
      |> cast(params, attrs)
      |> validate_required([:label, :name, :content, :scope])
      |> unique_constraint(:name)

    Enum.reduce(@validations, changeset, fn validation, changeset ->
      validate(changeset, validation, struct)
    end)
  end

  defp validate(%{valid?: true} = changeset, :repeated_group_names, _) do
    changeset
    |> get_field(:content)
    |> Enum.frequencies_by(&Map.get(&1, "name"))
    |> Enum.max_by(fn {_, count} -> count end, fn -> {:none, 0} end)
    |> case do
      {:none, 0} -> add_error(changeset, :content, "invalid_content.no_groups")
      {name, count} when count > 1 -> add_error(changeset, :content, "repeated.group", name: name)
      _ -> changeset
    end
  end

  defp validate(%{valid?: true} = changeset, :repeated_names, _) do
    content = get_field(changeset, :content)

    if Enum.any?(content, &match?(%{"fields" => nil}, &1)) do
      add_error(changeset, :content, "invalid_group.no_fields")
    else
      changeset
      |> flatten_content_fields()
      |> Enum.frequencies_by(&Map.get(&1, "name"))
      |> Enum.max_by(fn {_, count} -> count end, fn -> {:none, 0} end)
      |> case do
        {:none, 0} ->
          add_error(changeset, :content, "invalid_group.no_fields")

        {name, count} when count > 1 ->
          add_error(changeset, :content, "repeated.field", name: name)

        _ ->
          changeset
      end
    end
  end

  defp validate(%{valid?: true} = changeset, :name_and_types, %{id: id}) do
    templates =
      Enum.filter(Templates.list_templates(), fn template -> Map.get(template, :id) != id end)

    changeset
    |> flatten_content_fields()
    |> Enum.filter(fn field -> Map.has_key?(field, "name") && Map.has_key?(field, "type") end)
    |> Enum.into(Map.new(), fn field -> {Map.get(field, "name"), Map.get(field, "type")} end)
    |> validate_content(templates)
    |> case do
      :ok ->
        changeset

      {:error, error} ->
        name = Keyword.get(error, :name)
        type = Keyword.get(error, :type)
        add_error(changeset, :content, "invalid.type", name: name, type: type)
    end
  end

  defp validate(%{valid?: true} = changeset, :subscribable, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(&Map.get(&1, "subscribable"))
    |> Enum.reject(&fixed_values/1)
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.subscribable", name: Map.get(field, "name"))
    end
  end

  defp validate(%{valid?: true} = changeset, :group_names, _) do
    changeset
    |> get_field(:content)
    |> Enum.filter(&empty_or_nil?(Map.get(&1, "name")))
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.group.name", name: Map.get(field, "name"))
    end
  end

  defp validate(%{valid?: true} = changeset, :field_names, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(&empty_or_nil?(Map.get(&1, "name")))
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.name", name: Map.get(field, "name"))
    end
  end

  defp validate(%{valid?: true} = changeset, :field_label, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(&empty_or_nil?(Map.get(&1, "label")))
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.label", name: Map.get(field, "name"))
    end
  end

  defp validate(%{valid?: true} = changeset, :widget, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(&empty_or_nil?(Map.get(&1, "widget")))
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.widget", name: Map.get(field, "name"))
    end
  end

  defp validate(%{valid?: true} = changeset, :type, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(&empty_or_nil?(Map.get(&1, "type")))
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.type", name: Map.get(field, "name"))
    end
  end

  defp validate(%{valid?: true} = changeset, :cardinality, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(&empty_or_nil?(Map.get(&1, "cardinality")))
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.cardinality", name: Map.get(field, "name"))
    end
  end

  defp validate(%{valid?: true} = changeset, :user_roles, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(
      &(Map.get(&1, "type") === "user" &&
          empty_or_nil?(Map.get(&1, "values")["role_users"]))
    )
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.role_users",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(%{valid?: true} = changeset, :group_roles, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(
      &(Map.get(&1, "type") === "user_group" &&
          empty_or_nil?(Map.get(&1, "values")["role_groups"]))
    )
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.role_groups",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(%{valid?: true} = changeset, :type_hierarchy, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(
      &(Map.get(&1, "type") === "hierarchy" && empty_or_nil?(Map.get(&1, "values")["hierarchy"]))
    )
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.hierarchy",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(%{valid?: true} = changeset, :type_table, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(
      &(Map.get(&1, "type") === "table" && empty_or_nil?(Map.get(&1, "values")["table_columns"]))
    )
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.table_columns",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(%{valid?: true} = changeset, :dropdown_string_value, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(
      &(Map.get(&1, "widget") in ["dropdown", "radio", "checkout"] &&
          Map.get(&1, "type") === "string" && empty_or_nil?(Map.get(&1, "values")))
    )
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.type", name: Map.get(field, "name"))
    end
  end

  defp validate(%{valid?: true} = changeset, :depending_domain, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(
      &(Map.get(&1, "widget") in ["dropdown", "radio", "checkout"] &&
          Map.get(&1, "type") === "string" && Map.get(&1, "values")["domain"] === %{})
    )
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.domain.field",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(%{valid?: true} = changeset, :depending_domain_list, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(fn field ->
      Map.get(field, "widget") in ["dropdown", "radio", "checkout"] &&
        Map.get(field, "type") === "string" &&
        Map.get(field, "values")["domain"] &&
        field["values"]["domain"]
        |> Map.values()
        |> Enum.any?(&empty_or_nil?(&1))
    end)
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.domain.list",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(%{valid?: true} = changeset, :depending_field, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(fn field ->
      Map.get(field, "widget") in ["dropdown", "radio", "checkout"] &&
        Map.get(field, "type") === "string" &&
        Map.get(field, "values")["switch"] &&
        field["values"]["switch"]
        |> Map.values()
        |> Enum.any?(&empty_or_nil?(&1))
    end)
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.switch",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(%{valid?: true} = changeset, :fixed_list, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(
      &(Map.get(&1, "widget") in ["dropdown", "radio", "checkout"] &&
          Map.get(&1, "type") === "string" && Map.get(&1, "values")["fixed"] === [])
    )
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.fixed", name: Map.get(field, "name"))
    end
  end

  defp validate(%{valid?: true} = changeset, :key_value_list, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(
      &(Map.get(&1, "widget") in ["dropdown", "radio", "checkout"] &&
          Map.get(&1, "type") === "string" && Map.get(&1, "values")["fixed_tuple"] === [])
    )
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.values.fixed_tuple",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(%{valid?: true} = changeset, :conditional_visibility, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(&(Map.get(&1, "depends") && empty_or_nil?(Map.get(&1, "depends")["to_be"])))
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.depends.to_be",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(%{valid?: true} = changeset, :mandatory_depending, _) do
    changeset
    |> flatten_content_fields()
    |> Enum.filter(
      &(Map.get(&1, "mandatory") && empty_or_nil?(Map.get(&1, "mandatory")["to_be"]))
    )
    |> case do
      [] ->
        changeset

      [field | _] ->
        add_error(changeset, :content, "invalid.field.mandatory.to_be",
          name: Map.get(field, "name")
        )
    end
  end

  defp validate(changeset, _, _), do: changeset

  defp flatten_content_fields(changeset) do
    changeset
    |> get_field(:content)
    |> Enum.flat_map(&Map.get(&1, "fields"))
  end

  defp validate_content(content, templates) do
    templates
    |> Enum.map(&Map.get(&1, :content))
    |> List.flatten()
    |> Enum.map(&Map.get(&1, "fields"))
    |> List.flatten()
    |> fields_against_content(content)
  end

  defp fields_against_content([head | tail], content) do
    name = Map.get(head, "name")
    type = Map.get(head, "type")

    cond do
      is_nil(Map.get(content, name)) ->
        fields_against_content(tail, content)

      Map.get(content, name) == type ->
        fields_against_content(tail, content)

      true ->
        {:error, [name: name, type: type]}
    end
  end

  defp fields_against_content([], _), do: :ok

  defp fixed_values(%{"values" => %{"fixed" => _}}), do: true
  defp fixed_values(%{"values" => %{"fixed_tuple" => _}}), do: true
  defp fixed_values(_), do: false

  defp empty_or_nil?(value) do
    value in [nil, "", [], %{}]
  end
end
