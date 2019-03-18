defmodule TdDfWeb.TemplateControllerTest do
  use TdDfWeb.ConnCase
  use PhoenixSwagger.SchemaTest, "priv/static/swagger.json"

  import TdDfWeb.Authentication, only: :functions

  alias Poison, as: JSON
  alias TdDf.AclLoader.MockAclLoaderResolver
  alias TdDf.MockTaxonomyResolver
  alias TdDf.Permissions.MockPermissionResolver

  alias TdDf.Templates
  alias TdDf.Templates.Template
  alias TdDfWeb.ApiServices.MockTdAuthService
  @df_cache Application.get_env(:td_df, :df_cache)

  @create_attrs %{content: [], label: "some name", name: "some_name", scope: "bg"}
  @generic_attrs %{
    content: [%{type: "type1", required: true, name: "name1", max_size: 100}],
    label: "generic true",
    name: "generic_true",
    scope: "bg"
  }
  @create_attrs_generic_true %{
    content: [%{includes: ["generic_true"]}, %{other_field: "other_field"}],
    label: "some name",
    name: "some_name",
    scope: "bg"
  }
  @create_attrs_generic_false %{
    content: [%{includes: ["generic_false"]}, %{other_field: "other_field"}],
    label: "some name",
    name: "some_name",
    scope: "bg"
  }
  @others_create_attrs_generic_true %{
    content: [%{includes: ["generic_true", "generic_false"]}, %{other_field: "other_field"}],
    label: "some name",
    name: "some_name",
    scope: "bg"
  }
  @update_attrs %{content: [], label: "some updated name", name: "some_name", scope: "bg"}
  @invalid_attrs %{content: nil, label: nil,  name: nil}

  def fixture(:template) do
    {:ok, template} = Templates.create_template(@create_attrs)
    template
  end

  setup_all do
    start_supervised(MockAclLoaderResolver)
    start_supervised(MockPermissionResolver)
    start_supervised(MockTdAuthService)
    start_supervised(MockTaxonomyResolver)
    start_supervised(@df_cache)
    :ok
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    @tag :admin_authenticated
    test "lists all templates", %{conn: conn, swagger_schema: schema} do
      conn = get(conn, template_path(conn, :index))
      validate_resp_schema(conn, schema, "TemplatesResponse")
      assert json_response(conn, 200)["data"] == []
    end

    @tag :admin_authenticated
    test "lists all templates filtered by scope", %{conn: conn, swagger_schema: schema} do
      conn = post(conn, template_path(conn, :create), template: @generic_attrs)
      validate_resp_schema(conn, schema, "TemplateResponse")

      conn = recycle_and_put_headers(conn)

      conn = get(conn, template_path(conn, :index), scope: "bg")
      validate_resp_schema(conn, schema, "TemplatesResponse")
      assert length(json_response(conn, 200)["data"]) == 1

      conn = recycle_and_put_headers(conn)

      conn = get(conn, template_path(conn, :index), scope: "dd")
      validate_resp_schema(conn, schema, "TemplatesResponse")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "show" do
    @tag :admin_authenticated
    test "renders preprocessed template", %{conn: conn, swagger_schema: schema} do
      role_name = "test_role"
      domain_id = "1"
      user_id = "10"
      username = "username"

      MockAclLoaderResolver.put_user(user_id, %{full_name: username})
      MockAclLoaderResolver.set_acl_roles("domain", domain_id, [role_name])
      MockAclLoaderResolver.set_acl_role_users("domain", domain_id, role_name, [user_id])
      MockTaxonomyResolver.set_domain_parents(domain_id, [])

      {:ok, template} = Templates.create_template(%{
        "name" => "template_name",
        "label" => "template_label",
        "scope" => "bg",
        "content" => [
          %{
            "name" => "name1",
            "type" => "user",
            "values" => %{"role_users" => role_name}
          }
        ]
      })

      conn = get(conn, template_path(conn, :show, template.id, domain_id: domain_id))
      validate_resp_schema(conn, schema, "TemplateResponse")
      expected_values = %{
        "role_users" => role_name,
        "processed_users" => [username]
      }
      assert Enum.at(json_response(conn, 200)["data"]["content"], 0)["values"] == expected_values
    end
  end

  describe "create template" do
    @tag :admin_authenticated
    test "renders template when data is valid", %{conn: conn, swagger_schema: schema} do
      conn = post(conn, template_path(conn, :create), template: @create_attrs)
      validate_resp_schema(conn, schema, "TemplateResponse")
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle_and_put_headers(conn)
      conn = get(conn, template_path(conn, :show, id))
      validate_resp_schema(conn, schema, "TemplateResponse")

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "content" => [],
               "label" => "some name",
               "name" => "some_name",
               "scope" => "bg"
             }
    end

    @tag :admin_authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, template_path(conn, :create), template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag :admin_authenticated
    test "renders template with valid includes", %{conn: conn, swagger_schema: schema} do
      conn = post(conn, template_path(conn, :create), template: @generic_attrs)
      validate_resp_schema(conn, schema, "TemplateResponse")

      conn = recycle_and_put_headers(conn)
      conn = post(conn, template_path(conn, :create), template: @create_attrs_generic_true)
      validate_resp_schema(conn, schema, "TemplateResponse")
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle_and_put_headers(conn)
      conn = get(conn, template_path(conn, :load_and_show, id))
      validate_resp_schema(conn, schema, "TemplateResponse")

      assert JSON.encode(json_response(conn, 200)["data"]) ==
               JSON.encode(%{
                 "id" => id,
                 "content" => [
                   %{other_field: "other_field"},
                   %{type: "type1", required: true, name: "name1", max_size: 100}
                 ],
                 "label" => "some name",
                 "name" => "some_name",
                 "scope" => "bg"
               })
    end

    @tag :admin_authenticated
    test "renders template with invalid includes", %{conn: conn, swagger_schema: schema} do
      conn = post(conn, template_path(conn, :create), template: @generic_attrs)
      validate_resp_schema(conn, schema, "TemplateResponse")

      conn = recycle_and_put_headers(conn)
      conn = post(conn, template_path(conn, :create), template: @create_attrs_generic_false)
      validate_resp_schema(conn, schema, "TemplateResponse")
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle_and_put_headers(conn)
      conn = get(conn, template_path(conn, :load_and_show, id))
      validate_resp_schema(conn, schema, "TemplateResponse")

      assert JSON.encode(json_response(conn, 200)["data"]) ==
               JSON.encode(%{
                 "id" => id,
                 "content" => [%{other_field: "other_field"}],
                 "label" => "some name",
                 "name" => "some_name",
                 "scope" => "bg"
               })
    end

    @tag :admin_authenticated
    test "renders template with valid and invalid includes", %{conn: conn, swagger_schema: schema} do
      conn = post(conn, template_path(conn, :create), template: @generic_attrs)
      validate_resp_schema(conn, schema, "TemplateResponse")

      conn = recycle_and_put_headers(conn)
      conn = post(conn, template_path(conn, :create), template: @others_create_attrs_generic_true)
      validate_resp_schema(conn, schema, "TemplateResponse")
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle_and_put_headers(conn)
      conn = get(conn, template_path(conn, :load_and_show, id))
      validate_resp_schema(conn, schema, "TemplateResponse")

      assert JSON.encode(json_response(conn, 200)["data"]) ==
               JSON.encode(%{
                 "id" => id,
                 "content" => [
                   %{other_field: "other_field"},
                   %{type: "type1", required: true, name: "name1", max_size: 100}
                 ],
                 "label" => "some name",
                 "name" => "some_name",
                 "scope" => "bg"
               })
    end
  end

  describe "update template" do
    setup [:create_template]

    @tag :admin_authenticated
    test "renders template when data is valid", %{
      conn: conn,
      swagger_schema: schema,
      template: %Template{id: id} = template
    } do
      conn = put(conn, template_path(conn, :update, template), template: @update_attrs)
      validate_resp_schema(conn, schema, "TemplateResponse")
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = recycle_and_put_headers(conn)
      conn = get(conn, template_path(conn, :show, id))
      validate_resp_schema(conn, schema, "TemplateResponse")

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "content" => [],
               "label" => "some updated name",
               "name" => "some_name",
               "scope" => "bg"
             }
    end

    @tag :admin_authenticated
    test "renders errors when data is invalid", %{conn: conn, template: template} do
      conn = put(conn, template_path(conn, :update, template), template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete template" do
    setup [:create_template]

    @tag :admin_authenticated
    test "deletes chosen template", %{conn: conn, template: template} do
      conn = delete(conn, template_path(conn, :delete, template))
      assert response(conn, 204)
      conn = recycle_and_put_headers(conn)

      assert_error_sent(404, fn ->
        get(conn, template_path(conn, :show, template))
      end)
    end
  end

  defp create_template(_) do
    template = fixture(:template)
    {:ok, template: template}
  end
end
