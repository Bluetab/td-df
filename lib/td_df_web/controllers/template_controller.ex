defmodule TdDfWeb.TemplateController do
  use TdDfWeb, :controller
  use PhoenixSwagger

  import Canada, only: [can?: 2]

  alias TdCache.Templates.Preprocessor
  alias TdDf.Templates
  alias TdDf.Templates.Template
  alias TdDfWeb.SwaggerDefinitions

  require Logger

  action_fallback(TdDfWeb.FallbackController)

  def swagger_definitions do
    SwaggerDefinitions.template_swagger_definitions()
  end

  swagger_path :index do
    description("List Templates")
    response(200, "OK", Schema.ref(:TemplatesResponse))
  end

  def index(conn, params) do
    templates = Templates.list_templates(params)
    render(conn, "index.json", templates: templates)
  end

  swagger_path :create do
    description("Creates a Template")
    produces("application/json")

    parameters do
      template(:body, Schema.ref(:TemplateCreateUpdate), "Template create attrs")
    end

    response(201, "Created", Schema.ref(:TemplateResponse))
    response(400, "Client Error")
  end

  def create(conn, %{"template" => template}) do
    claims = conn.assigns[:current_resource]

    with {:can, true} <- {:can, can?(claims, manage(template))},
         {:ok, %Template{} = template} <- Templates.create_template(template) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.template_path(conn, :show, template))
      |> render("show.json", template: template)
    end
  end

  swagger_path :show do
    description("Show Template")
    produces("application/json")

    parameters do
      id(:path, :integer, "Template ID", required: true)
    end

    response(200, "OK", Schema.ref(:TemplateResponse))
    response(400, "Client Error")
  end

  def show(conn, %{"id" => id} = params) do
    claims = conn.assigns[:current_resource]

    preprocess_params = format_preprocess_params(params, claims)

    template =
      id
      |> Templates.get_template!()
      |> Preprocessor.preprocess_template(preprocess_params)

    render(conn, "show.json", template: template)
  end

  swagger_path :update do
    description("Updates Template")
    produces("application/json")

    parameters do
      template(:body, Schema.ref(:TemplateCreateUpdate), "Template update attrs")
      id(:path, :integer, "Template ID", required: true)
    end

    response(200, "OK", Schema.ref(:TemplateResponse))
    response(400, "Client Error")
  end

  def update(conn, %{"id" => id, "template" => template_params}) do
    claims = conn.assigns[:current_resource]
    template = Templates.get_template!(id)

    with {:can, true} <- {:can, can?(claims, manage(template))},
         {:ok, %Template{} = template} <- Templates.update_template(template, template_params) do
      render(conn, "show.json", template: template)
    end
  end

  swagger_path :delete do
    description("Delete Template")
    produces("application/json")

    parameters do
      id(:path, :integer, "Template ID", required: true)
    end

    response(204, "OK")
    response(400, "Client Error")
  end

  def delete(conn, %{"id" => id}) do
    claims = conn.assigns[:current_resource]
    template = Templates.get_template!(id)

    with {:can, true} <- {:can, can?(claims, manage(template))},
         {:ok, %Template{}} <- Templates.delete_template(template) do
      send_resp(conn, :no_content, "")
    end
  end

  defp format_preprocess_params(%{"domain_id" => domain_id}, claims) do
    %{claims: claims, domain_ids: [String.to_integer(domain_id)]}
  end

  defp format_preprocess_params(%{"domain_ids" => domain_ids}, claims) do
    domain_ids =
      domain_ids
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    %{claims: claims, domain_ids: domain_ids}
  end

  defp format_preprocess_params(_, claims) do
    %{claims: claims}
  end
end
