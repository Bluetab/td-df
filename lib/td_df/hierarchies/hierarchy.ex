defmodule TdDf.Hierarchies.Hierarchy do
  @moduledoc "Ecto Schema module for hierarchies"

  use Ecto.Schema

  import Ecto.Changeset

  alias TdDf.Hierarchies.Node

  schema "hierarchies" do
    field(:name, :string)
    field(:description, :string)
    has_many :nodes, Node

    timestamps(type: :utc_datetime)
  end

  @fields [:id, :name, :description, :nodes, :inserted_at, :updated_at]

  def changeset(%__MODULE__{} = struct, params) do
    do_changeset(struct, params)
  end

  defp do_changeset(%__MODULE__{} = struct, %{} = params, attrs \\ [:id, :name, :description]) do
    struct
    |> cast(params, attrs)
    |> validate_required([:name])
    |> validate_siblings_names(params)
    |> unique_constraint(:name)
  end

  defp validate_siblings_names(changeset, %{"nodes" => nodes}) do
    list =
      Enum.map(nodes, fn node ->
        {Map.get(node, "parent_id"), Map.get(node, "name")}
      end)

    case list -- Enum.uniq(list) do
      [_ | _] = duplicates ->
        add_error(changeset, :validate_siblings_names, "duplicated",
          duplicates: Enum.uniq(duplicates)
        )

      _ ->
        changeset
    end
  end

  defp validate_siblings_names(changeset, _), do: changeset

  def to_map(%__MODULE__{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.take(@fields)
  end
end
