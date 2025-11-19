defmodule TdDf.Cache.TemplateLoaderTest do
  use TdDf.DataCase

  alias TdDf.Cache.TemplateLoader
  alias TdDf.Repo

  setup do
    on_exit(fn -> TdCache.Redix.del!("template*") end)
  end

  describe "reload/0" do
    test "returns {:ok, count} tuple" do
      assert {:ok, 1} = TemplateLoader.reload()
    end

    test "reloads multiple templates" do
      insert(:template)
      insert(:template)
      assert {:ok, 3} = TemplateLoader.reload()
    end

    test "reloads templates with different scopes" do
      insert(:template, scope: "bg")
      insert(:template, scope: "dq")
      insert(:template, scope: "ca")
      assert {:ok, 4} = TemplateLoader.reload()
    end

    test "reloads templates with complex content" do
      insert(:template,
        content: [
          %{
            "name" => "group1",
            "fields" => [
              %{
                "name" => "field1",
                "label" => "Field 1",
                "type" => "string",
                "widget" => "text",
                "cardinality" => "1"
              },
              %{
                "name" => "field2",
                "label" => "Field 2",
                "type" => "integer",
                "widget" => "number",
                "cardinality" => "?"
              }
            ]
          }
        ]
      )

      assert {:ok, 2} = TemplateLoader.reload()
    end

    test "reloads updated templates" do
      template = insert(:template)
      assert {:ok, 2} = TemplateLoader.reload()

      Ecto.Changeset.change(template, label: "updated label") |> Repo.update!()
      assert {:ok, 2} = TemplateLoader.reload()
    end

    test "handles templates with no content" do
      insert(:template, content: [])
      assert {:ok, 2} = TemplateLoader.reload()
    end
  end
end
