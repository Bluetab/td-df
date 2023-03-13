defmodule TdDfWeb.HierarchyView do
  use TdDfWeb, :view

  alias TdDfWeb.NodeView

  def render("index.json", %{hierarchies: hierarchies}) do
    %{data: render_many(hierarchies, __MODULE__, "hierarchy.json")}
  end

  def render("show.json", %{hierarchy: hierarchy}) do
    %{data: render_one(hierarchy, __MODULE__, "hierarchy_detail.json")}
  end

  def render("hierarchy.json", %{hierarchy: hierarchy}) do
    Map.take(hierarchy, [:id, :name, :description])
  end

  def render("hierarchy_detail.json", %{hierarchy: hierarchy}) do
    hierarchy
    |> Map.take([
      :id,
      :name,
      :description
    ])
    |> Map.put(:nodes, render_one(hierarchy, __MODULE__, "nodes.json"))
  end

  def render("nodes.json", %{hierarchy: %{nodes: nodes}}) when is_list(nodes) do
    render_many(nodes, NodeView, "node.json")
  end

  def render("nodes.json", _), do: []
end

defmodule TdDfWeb.NodeView do
  use TdDfWeb, :view

  def render("nodes.json", %{node: nodes}) do
    render_one(nodes, __MODULE__, "node.json")
  end

  def render("node.json", %{node: node}) do
    node
    |> Map.take([
      :description,
      :name,
      :node_id,
      :parent_id
    ])
    |> Map.put(:key, "#{node.hierarchy_id}_#{node.node_id}")
  end
end
