defmodule TdDf.Templates.Template do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
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
    |> validate_required([:label, :name, :content])
    |> validate_format(:name, ~r/^[A-z0-9 ]*$/)
    |> validate_repeated_names()
    |> unique_constraint(:name)
  end

  defp validate_repeated_names(%{valid?: true} = changeset) do
    changeset
    |> get_field(:content)
    |> Enum.group_by(&Map.get(&1, "name"))
    |> Enum.filter(fn {_key, values} -> Enum.count(values) > 1 end)
    |> case do
      [] ->
        changeset

      [repeated | _] ->
        add_error(changeset, :content, "repeated.field", name: elem(repeated, 0))
    end
  end

  defp validate_repeated_names(changeset), do: changeset
end
