defmodule TdDfWeb.TemplateRelationController do
  require Logger
  use TdDfWeb, :controller
  use PhoenixSwagger

  alias TdDf.TemplatePreprocessor
  alias TdDf.Templates
  alias TdDf.Templates.TemplateRelation
  alias TdDfWeb.SwaggerDefinitions

  action_fallback TdDfWeb.FallbackController

  def swagger_definitions do
    SwaggerDefinitions.template_swagger_definitions()
  end

  swagger_path :index do
    description("List Template Relations")
    response(200, "OK", Schema.ref(:TemplateRelationsResponse))
  end

  def index(conn, _params) do
    template_relations = Templates.list_template_relations()
    render(conn, "index.json", template_relations: template_relations)
  end

  swagger_path :create do
    description("Creates a Template Relation")
    produces("application/json")

    parameters do
      template(:body, Schema.ref(:TemplateRelationCreateUpdate), "Template Relation create attrs")
    end

    response(201, "Created", Schema.ref(:TemplateRelationResponse))
    response(400, "Client Error")
  end

  def create(conn, %{"template_relation" => template_relation_params}) do
    with {:ok, %TemplateRelation{} = template_relation} <-
      Templates.create_template_relation(template_relation_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", template_relation_path(conn, :show, template_relation))
      |> render("show.json", template_relation: template_relation)
    end
  end

  swagger_path :show do
    description("Show Template Relation")
    produces("application/json")

    parameters do
      id(:path, :integer, "Template Relation ID", required: true)
    end

    response(200, "OK", Schema.ref(:TemplateRelationResponse))
    response(400, "Client Error")
  end

  def show(conn, %{"id" => id}) do
    template_relation = Templates.get_template_relation!(id)
    render(conn, "show.json", template_relation: template_relation)
  end

  swagger_path :update do
    description("Updates Template Relation")
    produces("application/json")

    parameters do
      template(:body, Schema.ref(:TemplateRelationCreateUpdate), "Template Relation update attrs")
      id(:path, :integer, "Template Relation ID", required: true)
    end

    response(200, "OK", Schema.ref(:TemplateRelationResponse))
    response(400, "Client Error")
  end

  def update(conn, %{"id" => id, "template_relation" => template_relation_params}) do
    template_relation = Templates.get_template_relation!(id)

    with {:ok, %TemplateRelation{} = template_relation} <-
      Templates.update_template_relation(template_relation, template_relation_params) do
      render(conn, "show.json", template_relation: template_relation)
    end
  end

  swagger_path :delete do
    description("Delete Template Relation")
    produces("application/json")

    parameters do
      id(:path, :integer, "Template Relation ID", required: true)
    end

    response(204, "OK")
    response(400, "Client Error")
  end

  def delete(conn, %{"id" => id}) do
    template_relation = Templates.get_template_relation!(id)
    with {:ok, %TemplateRelation{}} <- Templates.delete_template_relation(template_relation) do
      send_resp(conn, :no_content, "")
    end
  end

  swagger_path :get_related_templates do
    description("List Object Related Templates")

    parameters do
      resource_id(:query, :integer, "Related Object ID", required: true)
      resource_type(:query, :string, "Related Object Type", required: true)
    end

    response(200, "OK", Schema.ref(:TemplatesResponse))
  end

  def get_related_templates(conn, %{
      "resource_id" => resource_id,
      "resource_type" => resource_type}) do

    user = conn.assigns[:current_user]

    results = resource_id
    |> String.to_integer
    |> Templates.list_related_template_ids(resource_type)
    |> Enum.map(&(&1.id_template))
    |> Templates.list_templates_by_id
    |> TemplatePreprocessor.preprocess_templates(
      %{resource_type: resource_type, resource_id: resource_id, user: user})

    templates = case results do
        [] ->
          case Templates.get_default_template do
            nil -> []
            default_template -> [default_template]
          end
        templates -> templates
    end

    render(conn, "templates.json", templates: templates)
  end
  def get_related_templates(conn, %{}) do
    render(conn, "templates.json", templates: [])
  end
end
