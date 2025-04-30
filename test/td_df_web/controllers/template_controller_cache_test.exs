defmodule TdDfWeb.TemplateControllerCacheTest do
  use TdDfWeb.ConnCase

  alias TdCache.TemplateCache
  alias TdDf.Templates
  alias TdDf.Templates.Template

  @create_attrs %{
    content: [
      %{
        "name" => "some_group",
        "fields" => [
          %{
            "name" => "some_field",
            "label" => "some label",
            "widget" => "some_widget",
            "type" => "some_type",
            "cardinality" => "?"
          }
        ]
      }
    ],
    label: "some label",
    name: "some_name",
    scope: "s1",
    subscope: "subscope1"
  }
  @update_attrs %{
    content: [
      %{
        "name" => "some_updated_group",
        "fields" => [
          %{
            "name" => "some_field",
            "label" => "some label",
            "widget" => "some_widget",
            "type" => "some_type",
            "cardinality" => "?"
          }
        ]
      }
    ],
    label: "some updated label",
    name: "some_name",
    scope: "s2",
    subscope: "subscope2"
  }

  setup %{conn: conn} do
    [conn: put_req_header(conn, "accept", "application/json")]
  end

  describe "create template" do
    @tag :admin_authenticated
    test "writes data to cache when creating", %{conn: conn} do
      conn = post(conn, Routes.template_path(conn, :create), template: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      template_cache = TemplateCache.get_by_name!("some_name")
      template = Templates.get_template!(id)

      assert template_cache == %{
               id: id,
               content: [
                 %{
                   "name" => "some_group",
                   "fields" => [
                     %{
                       "name" => "some_field",
                       "label" => "some label",
                       "widget" => "some_widget",
                       "type" => "some_type",
                       "cardinality" => "?"
                     }
                   ]
                 }
               ],
               label: "some label",
               name: "some_name",
               scope: "s1",
               subscope: "subscope1",
               updated_at: to_string(template.updated_at)
             }
    end
  end

  describe "update template" do
    setup :create_template

    @tag :admin_authenticated
    test "refreshes cache data when updates", %{
      conn: conn,
      template: %Template{id: id} = template
    } do
      :timer.sleep(1000)
      conn = put(conn, Routes.template_path(conn, :update, template), template: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]
      template_cache = TemplateCache.get_by_name!("some_name")
      template = Templates.get_template!(id)

      assert template_cache == %{
               id: id,
               content: [
                 %{
                   "name" => "some_updated_group",
                   "fields" => [
                     %{
                       "name" => "some_field",
                       "label" => "some label",
                       "widget" => "some_widget",
                       "type" => "some_type",
                       "cardinality" => "?"
                     }
                   ]
                 }
               ],
               label: "some updated label",
               name: "some_name",
               scope: "s2",
               subscope: "subscope2",
               updated_at: to_string(template.updated_at)
             }
    end
  end

  describe "delete template" do
    setup :create_template

    @tag :admin_authenticated
    test "clean cache when template is deleted", %{conn: conn, template: template} do
      conn = delete(conn, Routes.template_path(conn, :delete, template))
      assert response(conn, 204)

      template = TemplateCache.get_by_name!("some_name")
      assert template == nil
    end
  end

  defp create_template(_) do
    {:ok, template} = Templates.create_template(@create_attrs)
    [template: template]
  end
end
