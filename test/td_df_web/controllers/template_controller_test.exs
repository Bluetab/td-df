defmodule TdDfWeb.TemplateControllerTest do
  use TdDfWeb.ConnCase
  use PhoenixSwagger.SchemaTest, "priv/static/swagger.json"

  alias TdDf.Templates
  alias TdDf.Templates.Template

  @create_attrs %{content: [], label: "some name", name: "some_name", scope: "bg"}
  @update_attrs %{content: [], label: "some updated name", name: "some_name", scope: "bg"}
  @invalid_attrs %{content: nil, label: nil, name: nil}

  def fixture(:template) do
    {:ok, template} = Templates.create_template(@create_attrs)
    template
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    @tag :user_authenticated
    test "lists all templates", %{conn: conn, swagger_schema: schema} do
      conn = get(conn, Routes.template_path(conn, :index))
      validate_resp_schema(conn, schema, "TemplatesResponse")
      assert [_ | _] = templates = json_response(conn, 200)["data"]

      assert Enum.any?(
               templates,
               &(Map.get(&1, "name") == "config_metabase" and Map.get(&1, "scope") == "ca")
             )
    end

    @tag :user_authenticated
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

      %{id: domain_id} = CacheHelpers.put_domain()
      %{id: user_id, full_name: full_name} = CacheHelpers.put_user()
      CacheHelpers.put_acl_role_users(domain_id, role_name, [user_id])

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

      assert %{"data" => data} =
               conn
               |> get(Routes.template_path(conn, :show, template.id, domain_id: domain_id))
               |> validate_resp_schema(schema, "TemplateResponse")
               |> json_response(:ok)

      assert %{"content" => [%{"fields" => [%{"values" => values}]}]} = data
      assert values == %{"role_users" => role_name, "processed_users" => [full_name]}
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

    @tag :service_authenticated
    test "can create templates when data is valid", %{conn: conn, swagger_schema: schema} do
      conn
      |> post(Routes.template_path(conn, :create), template: @create_attrs)
      |> validate_resp_schema(schema, "TemplateResponse")
      |> json_response(:created)
    end

    @tag :user_authenticated
    test "can not create new templates even with valid data", %{
      conn: conn,
      swagger_schema: schema
    } do
      conn
      |> post(Routes.template_path(conn, :create), template: @create_attrs)
      |> validate_resp_schema(schema, "TemplateResponse")
      |> json_response(:forbidden)
    end

    @tag :admin_authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.template_path(conn, :create), template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update template" do
    setup :create_template

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

    @tag :service_authenticated
    test "can update templates when data is valid", %{
      conn: conn,
      swagger_schema: schema,
      template: %Template{id: id} = template
    } do
      assert %{"data" => %{"id" => ^id}} =
               conn
               |> put(Routes.template_path(conn, :update, template), template: @update_attrs)
               |> validate_resp_schema(schema, "TemplateResponse")
               |> json_response(:ok)
    end

    @tag :user_authenticated
    test "can not udate templates even with valid data", %{
      conn: conn,
      swagger_schema: schema,
      template: %Template{id: _id} = template
    } do
      conn
      |> put(Routes.template_path(conn, :update, template), template: @update_attrs)
      |> validate_resp_schema(schema, "TemplateResponse")
      |> json_response(:forbidden)
    end

    @tag :admin_authenticated
    test "renders errors when data is invalid", %{conn: conn, template: template} do
      conn = put(conn, Routes.template_path(conn, :update, template), template: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete template" do
    setup :create_template

    @tag :admin_authenticated
    test "deletes chosen template", %{conn: conn, template: template} do
      assert conn
             |> delete(Routes.template_path(conn, :delete, template))
             |> response(:no_content)

      assert_error_sent :not_found, fn ->
        get(conn, Routes.template_path(conn, :show, template))
      end
    end

    @tag :service_authenticated
    test "can update templates when data is valid", %{
      conn: conn,
      template: template
    } do
      assert conn
             |> delete(Routes.template_path(conn, :delete, template))
             |> response(:no_content)

      assert_error_sent :not_found, fn ->
        get(conn, Routes.template_path(conn, :show, template))
      end
    end

    @tag :user_authenticated
    test "can not udate templates even with valid data", %{
      conn: conn,
      template: %{id: id} = template
    } do
      conn
      |> delete(Routes.template_path(conn, :delete, template))
      |> json_response(:forbidden)

      assert %{"data" => %{"id" => ^id}} =
               conn
               |> get(Routes.template_path(conn, :show, id))
               |> json_response(:ok)
    end
  end

  defp create_template(_) do
    template = fixture(:template)
    {:ok, template: template}
  end
end
