defmodule TdDf.Cache.HierarchyLoader do
  @moduledoc """
  Provides functionality to load templates into distributed cache
  """

  alias TdCache.HierarchyCache
  alias TdDf.Hierarchies

  require Logger

  def reload do
    Logger.info("Reloading hierarchies")
    hierarchies = Hierarchies.list_hierarchies_with_nodes()
    count = put_hierarchies(hierarchies, force: true, publish: false)
    Logger.info("Put #{count} hierarchies")
    {:ok, count}
  end

  def refresh(id) do
    put_hierarchy(id)
  end

  def delete(id) do
    {:ok, _} = HierarchyCache.delete(id)
  end

  defp put_hierarchy(id) do
    {:ok, _} =
      id
      |> Hierarchies.get_hierarchy_with_nodes!()
      |> add_key()
      |> HierarchyCache.put()
  end

  defp put_hierarchies(hierarchies, opts) do
    hierarchies
    |> Enum.map(&add_key(&1))
    |> Enum.map(&HierarchyCache.put(&1, opts))
    |> Enum.filter(&(&1 != {:ok, []}))
    |> Enum.count()
  end

  defp add_key(%{nodes: nodes} = hierarchy) do
    nodes
    |> Enum.map(fn node ->
      Map.put(node, :key, "#{node.hierarchy_id}_#{node.node_id}")
    end)
    |> (&Map.put(hierarchy, :nodes, &1)).()
  end
end
