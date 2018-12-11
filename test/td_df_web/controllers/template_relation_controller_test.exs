defmodule TdDfWeb.TemplateRelationControllerTest do
  use TdDfWeb.ConnCase

  import TdDfWeb.Authentication, only: :functions

  alias TdDf.AclLoader.MockAclLoaderResolver
  alias TdDf.MockTaxonomyResolver
  alias TdDf.Permissions.MockPermissionResolver
  alias TdDf.Templates
  alias TdDf.Templates.TemplateRelation
  alias TdDfWeb.ApiServices.MockTdAuthService
  @df_cache Application.get_env(:td_df, :df_cache)

  @create_attrs %{id_template: 1, resource_id: 3, resource_type: "some resource_type"}
  @update_attrs %{id_template: 2, resource_id: 4, resource_type: "some updated resource_type"}
  @invalid_attrs %{id_template: nil, resource_id: nil, resource_type: nil}

  def fixture(:template_relation) do
    {:ok, template_relation} = Templates.create_template_relation(@create_attrs)
    template_relation
  end

  setup_all do
    start_supervised(MockPermissionResolver)
    start_supervised(MockTdAuthService)
    start_supervised(MockAclLoaderResolver)
    start_supervised(MockTaxonomyResolver)
    start_supervised(@df_cache)
    :ok
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    @tag :admin_authenticated
    test "lists all template_relations", %{conn: conn} do
      conn = get conn, template_relation_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create template_relation" do
    @tag :admin_authenticated
    test "renders template_relation when data is valid", %{conn: conn} do
      conn = post conn, template_relation_path(conn, :create), template_relation: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle_and_put_headers(conn)
      conn = get conn, template_relation_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "id_template" => 1,
        "resource_id" => 3,
        "resource_type" => "some resource_type"}
    end

    @tag :admin_authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, template_relation_path(conn, :create), template_relation: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update template_relation" do
    setup [:create_template_relation]

    @tag :admin_authenticated
    test "renders template_relation when data is valid", %{conn: conn, template_relation: %TemplateRelation{id: id} = template_relation} do
      conn = put conn, template_relation_path(conn, :update, template_relation), template_relation: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = recycle_and_put_headers(conn)
      conn = get conn, template_relation_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "id_template" => 2,
        "resource_id" => 4,
        "resource_type" => "some updated resource_type"}
    end

    @tag :admin_authenticated
    test "renders errors when data is invalid", %{conn: conn, template_relation: template_relation} do
      conn = put conn, template_relation_path(conn, :update, template_relation), template_relation: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete template_relation" do
    setup [:create_template_relation]

    @tag :admin_authenticated
    test "deletes chosen template_relation", %{conn: conn, template_relation: template_relation} do
      conn = delete conn, template_relation_path(conn, :delete, template_relation)
      assert response(conn, 204)
      conn = recycle_and_put_headers(conn)

      assert_error_sent 404, fn ->
        get conn, template_relation_path(conn, :show, template_relation)
      end
    end
  end

  describe "list related templates" do
    @tag :admin_authenticated
    test "return empty list for non related template", %{conn: conn} do
      params = %{
        resource_id: 1,
        resource_type: "none"
      }
      conn = get conn, template_relation_path(conn, :get_related_templates, params)
      assert json_response(conn, 200)["data"] == []
    end

    @tag :admin_authenticated
    test "return one related template", %{conn: conn} do
      params = %{
        resource_id: 1,
        resource_type: "none"
      }

      template_args = %{
        name: "t1",
        label: "l1",
        is_default: false,
        content: [],
        scope: "bg"
      }

      {:ok, template} = Templates.create_template(template_args)
      Templates.create_template_relation(Map.put(params, :id_template, template.id))

      clean_template = render_template(template)

      conn = get conn, template_relation_path(conn, :get_related_templates, params)
      assert json_response(conn, 200)["data"] == [clean_template]
    end
  end

  defp render_template(template) do
    %{"id" => template.id,
      "label" => template.label,
      "name" => template.name,
      "content" => template.content,
      "is_default" => template.is_default,
      "scope" => "bg"
    }
  end

  defp create_template_relation(_) do
    template_relation = fixture(:template_relation)
    {:ok, template_relation: template_relation}
  end
end
