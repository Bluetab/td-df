defmodule TdDfWeb.TemplateControllerCacheTest do
  use TdDfWeb.ConnCase
  use PhoenixSwagger.SchemaTest, "priv/static/swagger.json"

  alias TdCache.TemplateCache
  alias TdDf.Permissions.MockPermissionResolver
  alias TdDf.Templates
  alias TdDf.Templates.Template
  alias TdDfWeb.ApiServices.MockTdAuthService

  @create_attrs %{content: [], label: "some label", name: "some_name", scope: "s1"}
  @update_attrs %{content: [], label: "some updated label", name: "some_name", scope: "s2"}

  def fixture(:template) do
    {:ok, template} = Templates.create_template(@create_attrs)
    template
  end

  setup_all do
    start_supervised(MockPermissionResolver)
    start_supervised(MockTdAuthService)
    :ok
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create template" do
    @tag :admin_authenticated
    test "writes data to cache when creating", %{conn: conn} do
      conn = post(conn, Routes.template_path(conn, :create), template: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      template = TemplateCache.get_by_name!("some_name")

      assert template == %{
               id: id,
               content: [],
               label: "some label",
               name: "some_name",
               scope: "s1"
             }
    end
  end

  describe "update template" do
    setup [:create_template]

    @tag :admin_authenticated
    test "refreshes cache data when updates", %{
      conn: conn,
      template: %Template{id: id} = template
    } do
      conn = put(conn, Routes.template_path(conn, :update, template), template: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      template = TemplateCache.get_by_name!("some_name")

      assert template == %{
               id: id,
               content: [],
               label: "some updated label",
               name: "some_name",
               scope: "s2"
             }
    end
  end

  describe "delete template" do
    setup [:create_template]

    @tag :admin_authenticated
    test "clean cache when template is deleted", %{conn: conn, template: template} do
      conn = delete(conn, Routes.template_path(conn, :delete, template))
      assert response(conn, 204)

      template = TemplateCache.get_by_name!("some_name")
      assert template == nil
    end
  end

  defp create_template(_) do
    template = fixture(:template)
    {:ok, template: template}
  end
end
