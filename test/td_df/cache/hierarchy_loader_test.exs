defmodule TdDf.Cache.HierarchyLoaderTest do
  use TdDf.DataCase

  alias TdDf.Cache.HierarchyLoader
  alias TdDf.Repo

  setup do
    on_exit(fn -> TdCache.Redix.del!("hierarchy*") end)
  end

  describe "reload/0" do
    test "returns {:ok, count} tuple" do
      insert(:hierarchy)
      assert {:ok, 1} = HierarchyLoader.reload()
    end

    test "reloads multiple hierarchies" do
      insert(:hierarchy)
      insert(:hierarchy)
      insert(:hierarchy)
      assert {:ok, 3} = HierarchyLoader.reload()
    end

    test "reloads hierarchies with nodes" do
      insert(:hierarchy, nodes: [build(:node, %{parent_id: nil})])

      insert(:hierarchy,
        nodes: [build(:node, %{parent_id: nil}), build(:node, %{parent_id: nil})]
      )

      assert {:ok, 2} = HierarchyLoader.reload()
    end

    test "returns zero count when no hierarchies exist" do
      assert {:ok, 0} = HierarchyLoader.reload()
    end

    test "reloads updated hierarchies" do
      hierarchy = insert(:hierarchy)
      assert {:ok, 1} = HierarchyLoader.reload()

      updated_hierarchy = Ecto.Changeset.change(hierarchy, name: "updated name") |> Repo.update!()
      assert updated_hierarchy.name == "updated name"
      assert {:ok, 1} = HierarchyLoader.reload()
    end
  end
end
