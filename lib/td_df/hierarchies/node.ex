defmodule TdDf.Hierarchies.Node do
  @moduledoc "Ecto Schema module for hierarchies"

  use Ecto.Schema

  import Ecto.Changeset

  alias TdDf.Hierarchies.Hierarchy

  @primary_key false
  schema "hierarchy_nodes" do
    field(:node_id, :integer)
    field(:parent_id, :integer)
    field(:name, :string)
    field(:description, :string)
    belongs_to :hierarchy, Hierarchy

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(%__MODULE__{} = struct, params) do
    do_changeset(struct, params)
  end

  defp do_changeset(
         %__MODULE__{} = struct,
         %{} = params,
         attrs \\ [:hierarchy_id, :node_id, :parent_id, :name, :description]
       ) do
    struct
    |> cast(params, attrs)
    |> validate_required([:hierarchy_id, :node_id, :name])
    |> unique_constraint([:hierarchy_id, :node_id])
    |> unique_constraint([:hierarchy_id, :parent_id, :name])
  end

  def to_map(changeset) do
    changeset
    |> apply_changes()
    |> Map.from_struct()
    |> Map.take([:hierarchy_id, :node_id, :parent_id, :name, :description])
  end
end
