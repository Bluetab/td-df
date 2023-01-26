defmodule TdDf.Hierarchies do
  @moduledoc """
  The Hierarchies context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias TdDf.Hierarchies.Hierarchy
  alias TdDf.Hierarchies.Node
  alias TdDf.Repo

  def list_hierarchies do
    Hierarchy
    |> order_by(desc: :updated_at, desc: :id)
    |> Repo.all()
  end

  def get_hierarchy!(id) do
    nodes_query = from n in Node, order_by: n.name

    Hierarchy
    |> preload(nodes: ^nodes_query)
    |> Repo.get!(id)
  end

  def delete_hierarchy(hierarchy) do
    Repo.delete(hierarchy)
  end

  def update_hierarchy(%{id: id}, params \\ %{}) do
    hierarchy_changeset =
      id
      |> get_hierarchy!
      |> Hierarchy.changeset(params)

    upsert_hierarchy(hierarchy_changeset, params)
  end

  def create_hierarchy(params \\ %{}) do
    hierarchy_changeset = Hierarchy.changeset(%Hierarchy{}, params)
    upsert_hierarchy(hierarchy_changeset, params)
  end

  defp upsert_hierarchy(hierarchy_changeset, params) do
    nodes_params = Map.get(params, "nodes")

    result =
      Multi.new()
      |> Multi.insert_or_update(:hierarchy, hierarchy_changeset)
      |> Multi.run(:nodes_structs, __MODULE__, :get_nodes_struct, [nodes_params])
      |> Multi.delete_all(:deleted_nodes, fn %{hierarchy: %{id: id}} ->
        where(Node, [n], n.hierarchy_id == ^id)
      end)
      |> Multi.insert_all(:nodes, Node, fn %{nodes_structs: nodes_structs} ->
        Enum.map(nodes_structs, &Map.put(&1, :inserted_at, DateTime.utc_now()))
      end)
      |> Repo.transaction()

    case result do
      {:error, _, error, _} ->
        {:error, error}

      {:ok, %{hierarchy: hierarchy, nodes_structs: nodes}} ->
        {:ok,
         hierarchy
         |> Hierarchy.to_map()
         |> Map.put(:nodes, nodes)}
    end
  end

  def get_nodes_struct(_multi, _, nil), do: {:ok, []}

  def get_nodes_struct(_multi, %{hierarchy: %{id: hierarchy_id}}, nodes_params) do
    Enum.reduce_while(nodes_params, {:ok, []}, fn node_params, {:ok, nodes_structs} ->
      node_struct = Node.changeset(%Node{}, Map.put(node_params, "hierarchy_id", hierarchy_id))

      case node_struct do
        %{valid?: true, errors: []} ->
          {:cont, {:ok, [Node.to_map(node_struct) | nodes_structs]}}

        %{errors: errors} ->
          {:halt, {:error, errors}}
      end
    end)
  end
end
