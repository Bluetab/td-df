defmodule TdDfWeb.TemplateControllerTest do
  use TdDfWeb.ConnCase
  use PhoenixSwagger.SchemaTest, "priv/static/swagger.json"

  alias TdCache.AclCache
  alias TdCache.UserCache
  alias TdDf.Templates
  alias TdDf.Templates.Template
  alias TdDfWeb.ApiServices.MockTdAuthService

  @create_attrs %{content: [], label: "some name", name: "some_name", scope: "bg"}
  @update_attrs %{content: [], label: "some updated name", name: "some_name", scope: "bg"}
  @invalid_attrs %{content: nil, label: nil, name: nil}

  def fixture(:template) do
    {:ok, template} = Templates.create_template(@create_attrs)
    template
  end

  setup_all do
    start_supervised(MockTdAuthService)
    :ok
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    @tag :admin_authenticated
    test "lists all templates", %{conn: conn, swagger_schema: schema} do
      conn = get(conn, Routes.template_path(conn, :index))
      validate_resp_schema(conn, schema, "TemplatesResponse")
      assert [_ | _] = templates = json_response(conn, 200)["data"]

      assert Enum.any?(
               templates,
               &(Map.get(&1, "name") == "config_metabase" and Map.get(&1, "scope") == "ca")
             )
    end

    @tag :admin_authenticated
    test "lists all templates filtered by scope", %{conn: conn, swagger_schema: schema} do
      insert(:template, scope: "bg")
      insert(:template, scope: "dd")

      assert %{"data" => data} =
               conn
               |> get(Routes.template_path(conn, :index), scope: "bg")
               |> validate_resp_schema(schema, "TemplatesResponse")
               |> json_response(:ok)

      assert length(data) == 1
    end
  end

  describe "show" do
    @tag :admin_authenticated
    test "renders preprocessed template", %{conn: conn, swagger_schema: schema} do
      role_name = "test_role"
      domain_id = "1"
      user_id = "10"
      username = "username"

      UserCache.put(%{id: user_id, full_name: username})
      AclCache.set_acl_roles("domain", domain_id, [role_name])
      AclCache.set_acl_role_users("domain", domain_id, role_name, [user_id])

      {:ok, template} =
        Templates.create_template(%{
          "name" => "template_name",
          "label" => "template_label",
          "scope" => "bg",
          "content" => [
            %{
              "name" => "test-group",
              "fields" => [
                %{
                  "name" => "name1",
                  "type" => "user",
                  "values" => %{"role_users" => role_name}
                }
              ]
            }
          ]
        })

      conn = get(conn, Routes.template_path(conn, :show, template.id, domain_id: domain_id))
      validate_resp_schema(conn, schema, "TemplateResponse")

      expected_values = %{
        "role_users" => role_name,
        "processed_users" => [username]
      }

      values =
        conn
        |> json_response(200)
        |> Map.get("data")
        |> Map.get("content")
        |> Enum.at(0)
        |> Map.get("fields")
        |> Enum.at(0)
        |> Map.get("values")

      assert values == expected_values
    end
  end

  describe "create template" do
    @tag :admin_authenticated
    test "renders template when data is valid", %{conn: conn, swagger_schema: schema} do
      assert %{"data" => data} =
               conn
               |> post(Routes.template_path(conn, :create), template: @create_attrs)
               |> validate_resp_schema(schema, "TemplateResponse")
               |> json_response(:created)

      assert %{"id" => id} = data

      assert %{"data" => data} =
               conn
               |> get(Routes.template_path(conn, :show, id))
               |> validate_resp_schema(schema, "TemplateResponse")
               |> json_response(:ok)

      assert data == %{
               "id" => id,
               "content" => [],
               "label" => "some name",
               "name" => "some_name",
               "scope" => "bg"
             }
    end

    @tag :admin_authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.template_path(conn, :create), template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
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
      assert %{"data" => data} =
               conn
               |> put(Routes.template_path(conn, :update, template), template: @update_attrs)
               |> validate_resp_schema(schema, "TemplateResponse")
               |> json_response(:ok)

      assert %{"id" => ^id} = data

      assert %{"data" => data} =
               conn
               |> get(Routes.template_path(conn, :show, id))
               |> validate_resp_schema(schema, "TemplateResponse")
               |> json_response(:ok)

      assert data == %{
               "id" => id,
               "content" => [],
               "label" => "some updated name",
               "name" => "some_name",
               "scope" => "bg"
             }
    end

    @tag :admin_authenticated
    test "renders errors when data is invalid", %{conn: conn, template: template} do
      conn = put(conn, Routes.template_path(conn, :update, template), template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete template" do
    setup [:create_template]

    @tag :admin_authenticated
    test "deletes chosen template", %{conn: conn, template: template} do
      assert conn
             |> delete(Routes.template_path(conn, :delete, template))
             |> response(:no_content)

      assert_error_sent :not_found, fn ->
        get(conn, Routes.template_path(conn, :show, template))
      end
    end
  end

  defp create_template(_) do
    template = fixture(:template)
    {:ok, template: template}
  end
end
