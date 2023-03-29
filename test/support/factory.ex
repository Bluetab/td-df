defmodule TdDf.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: TdDf.Repo

  def template_factory do
    %TdDf.Templates.Template{
      label: "some type",
      name: sequence("template_name"),
      content: []
    }
  end

  def domain_factory do
    %{
      id: System.unique_integer([:positive]),
      parent_id: nil,
      name: sequence("domain_name"),
      updated_at: DateTime.utc_now()
    }
  end

  def user_factory do
    %{
      id: System.unique_integer([:positive]),
      full_name: sequence("full_name"),
      user_name: sequence("user_name"),
      email: sequence("user_email") <> "@example.com"
    }
  end

  def group_factory do
    %{
      id: System.unique_integer([:positive]),
      name: sequence("group_name"),
      description: sequence("group_description")
    }
  end

  def hierarchy_factory(attrs) do
    %TdDf.Hierarchies.Hierarchy{
      id: System.unique_integer([:positive]),
      name: sequence("family_"),
      description: sequence("description_"),
      nodes: []
    }
    |> merge_attributes(attrs)
  end

  def node_factory(attrs) do
    name = sequence("node_")
    hierarchy_id = Map.get(attrs, :hierarchy_id, System.unique_integer([:positive]))
    node_id = Map.get(attrs, :node_id, System.unique_integer([:positive]))

    %TdDf.Hierarchies.Node{
      node_id: node_id,
      hierarchy_id: hierarchy_id,
      parent_id: System.unique_integer([:positive]),
      name: name,
      description: sequence("description_"),
      path: "/#{name}"
    }
    |> merge_attributes(attrs)
  end
end
