defmodule TdDf.Cache.HierarchyLoaderTest do
  use TdDf.DataCase

  alias TdDf.Cache.HierarchyLoader

  setup do
    on_exit(fn -> TdCache.Redix.del!("hierarchy*") end)
  end

  describe "reload/0" do
    test "returns {:ok, count} tuple" do
      insert(:hierarchy)
      assert {:ok, 1} = HierarchyLoader.reload()
    end
  end
end
