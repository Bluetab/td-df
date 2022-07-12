defmodule TdDf.Cache.TemplateLoaderTest do
  use TdDf.DataCase

  alias TdDf.Cache.TemplateLoader

  setup do
    on_exit(fn -> TdCache.Redix.del!("template*") end)
  end

  describe "reload/0" do
    test "returns {:ok, count} tuple" do
      assert {:ok, 1} = TemplateLoader.reload()
    end
  end
end
