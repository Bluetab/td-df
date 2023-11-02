defmodule TdCluster.ClusterTdDfTest do
  use ExUnit.Case
  use TdDf.DataCase

  alias TdCluster.Cluster

  @moduletag sandbox: :shared

  describe "test Cluster.TdDf functions" do
    test "get_template_by_name!/1" do
      template = insert(:template)

      assert {:ok, template} == Cluster.TdDf.get_template_by_name!(template.name)
    end

    test "list_templates_by_scope/1" do
      template = insert(:template, scope: "scope1")
      insert(:template, scope: "scope2")

      assert {:ok, [template]} == Cluster.TdDf.list_templates_by_scope("scope1")
    end

    test "get_template/1" do
      template = insert(:template)

      assert {:ok, template} == Cluster.TdDf.get_template(template.id)
    end
  end
end
