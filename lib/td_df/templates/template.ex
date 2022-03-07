defmodule TdDf.Templates.Template do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias TdDf.Templates
  alias TdDf.Templates.Template

  schema "templates" do
    field(:content, {:array, :map})
    field(:label, :string)
    field(:name, :string)
    field(:scope, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Template{} = template, attrs) do
    template
    |> cast(attrs, [:label, :name, :content, :scope])
    |> validate_required([:label, :name, :content, :scope])
    |> validate_repeated_group_names()
    |> validate_repeated_names()
    |> validate_name_and_types(template)
    |> validate_subscribable()
    |> unique_constraint(:name)
  end

  defp validate_repeated_group_names(%{valid?: true} = changeset) do
    changeset
    |> get_field(:content)
    |> Enum.frequencies_by(&Map.get(&1, "name"))
    |> Enum.max_by(fn {_, count} -> count end, fn -> {:none, 0} end)
    |> case do
      {name, count} when count > 1 -> add_error(changeset, :content, "repeated.group", name: name)
      _ -> changeset
    end
  end

  defp validate_repeated_group_names(changeset), do: changeset

  defp validate_repeated_names(%{valid?: true} = changeset) do
    changeset
    |> flatten_content_fields()
    |> Enum.frequencies_by(&Map.get(&1, "name"))
    |> Enum.max_by(fn {_, count} -> count end, fn -> {:none, 0} end)
    |> case do
      {name, count} when count > 1 -> add_error(changeset, :content, "repeated.field", name: name)
      _ -> changeset
    end
  end

  defp validate_repeated_names(changeset), do: changeset

  defp validate_name_and_types(%{valid?: true} = changeset, %{id: id}) do
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

  defp validate_name_and_types(changeset, _), do: changeset

  defp validate_subscribable(%{valid?: true} = changeset) do
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

  defp validate_subscribable(changeset), do: changeset

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
end
