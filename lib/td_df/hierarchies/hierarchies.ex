defmodule TdDf.Hierarchies do
  @moduledoc """
  The Hierarchies context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias TdDf.Cache.HierarchyLoader
  alias TdDf.Hierarchies.Hierarchy
  alias TdDf.Hierarchies.Node
  alias TdDf.Repo

  def list_hierarchies do
    Hierarchy
    |> order_by(desc: :updated_at, desc: :id)
    |> Repo.all()
  end

  def nodes_with_path do
    hierarchy_nodes_initial_query =
      Node
      |> where([n], is_nil(n.parent_id))
      |> select([n], %{
        hierarchy_id: n.hierarchy_id,
        node_id: n.node_id,
        parent_id: n.parent_id,
        path: fragment("'/' || ?", n.name)
      })

    hierarchy_nodes_recursion_query =
      Node
      |> join(:inner, [n], ct in "hierarchy_nodes_cte",
        on: n.parent_id == ct.node_id and n.hierarchy_id == ct.hierarchy_id
      )
      |> select([n, ct], %{
        hierarchy_id: n.hierarchy_id,
        node_id: n.node_id,
        parent_id: n.parent_id,
        path: fragment("? || '/' || ?", ct.path, n.name)
      })

    hierarchy_nodes_query =
      hierarchy_nodes_initial_query
      |> union_all(^hierarchy_nodes_recursion_query)

    Node
    |> recursive_ctes(true)
    |> with_cte("hierarchy_nodes_cte", as: ^hierarchy_nodes_query)
    |> join(:left, [n], t in "hierarchy_nodes_cte",
      on: n.node_id == t.node_id and n.hierarchy_id == t.hierarchy_id
    )
    |> select_merge([_n, ct], %{path: ct.path})
  end

  def list_hierarchies_with_nodes do
    Hierarchy
    |> preload(nodes: ^nodes_with_path())
    |> Repo.all()
  end

  def get_hierarchy_with_nodes!(id) do
    Hierarchy
    |> preload(nodes: ^nodes_with_path())
    |> Repo.get!(id)
  end

  def get_hierarchy!(id) do
    nodes_query = from n in Node, order_by: n.name

    Hierarchy
    |> preload(nodes: ^nodes_query)
    |> Repo.get!(id)
  end

  def delete_hierarchy(hierarchy) do
    hierarchy
    |> Repo.delete()
    |> clean_cache()
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
        |> refresh_cache()
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

  def refresh_cache({:ok, %{id: id}} = response) do
    HierarchyLoader.refresh(id)
    response
  end

  def refresh_cache(%{id: id} = hierarchy) do
    HierarchyLoader.refresh(id)
    hierarchy
  end

  def refresh_cache(response), do: response

  defp clean_cache({:ok, %{id: id}} = response) do
    HierarchyLoader.delete(id)
    response
  end

  defp clean_cache(response), do: response
end
