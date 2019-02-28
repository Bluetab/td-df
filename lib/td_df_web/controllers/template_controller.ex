defmodule TdDfWeb.TemplateController do
  require Logger
  use TdDfWeb, :controller
  use PhoenixSwagger

  alias TdDf.Templates
  alias TdDf.Templates.Preprocessor
  alias TdDf.Templates.Template
  alias TdDfWeb.ChangesetView
  alias TdDfWeb.ErrorView
  alias TdDfWeb.SwaggerDefinitions

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
    with {:ok, %Template{} = template} <- Templates.create_template(template) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", template_path(conn, :show, template))
      |> render("show.json", template: template)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ChangesetView, "error.json", changeset: changeset)

      error ->
        Logger.error("While creating template... #{inspect(error)}")

        conn
        |> put_status(:unprocessable_entity)
        |> render(ErrorView, :"422.json")
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
    user = conn.assigns[:current_user]

    domain_id = Map.get(params, "domain_id")

    preprocess_params =
      format_preprocess_params(%{
        domain_id: domain_id,
        user: user
      })

    template =
      id
      |> Templates.get_template!()
      |> Preprocessor.preprocess_template(preprocess_params)

    render(conn, "show.json", template: template)
  end

  swagger_path :load_and_show do
    description("Load and show Template")
    produces("application/json")

    parameters do
      id(:path, :integer, "Template ID", required: true)
    end

    response(200, "OK", Schema.ref(:TemplateResponse))
    response(400, "Client Error")
  end

  def load_and_show(conn, %{"id" => id}) do
    {:ok, template} = load_template(Templates.get_template!(id))
    render(conn, "show.json", template: template)
  end

  defp load_template(template) do
    includes =
      List.first(Enum.filter(Map.get(template, :content), fn field -> field["includes"] end))[
        "includes"
      ]

    case includes do
      nil -> {:ok, template}
      _ -> load_template(template, includes)
    end
  end

  defp load_template(template, includes) do
    includes =
      Enum.reduce(includes, [], fn name, acc ->
        case Templates.get_template_by_name(name) do
          nil -> acc
          _ -> [name] ++ acc
        end
      end)

    my_fields = Enum.reject(Map.get(template, :content), fn field -> field["includes"] end)

    case length(includes) do
      0 ->
        {:ok, Map.put(template, :content, my_fields)}

      _ ->
        final_fields =
          my_fields ++
            Enum.reduce(includes, [], fn templ, acc ->
              Map.get(Templates.get_template_by_name(templ), :content) ++ acc
            end)

        {:ok, Map.put(template, :content, final_fields)}
    end
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
    template = Templates.get_template!(id)

    update_params =
      template_params
      |> Map.drop([:name])

    with {:ok, %Template{} = template} <- Templates.update_template(template, update_params) do
      render(conn, "show.json", template: template)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ChangesetView, "error.json", changeset: changeset)

      error ->
        Logger.error("While updating template... #{inspect(error)}")

        conn
        |> put_status(:unprocessable_entity)
        |> render(ErrorView, :"422.json")
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
    template = Templates.get_template!(id)

    with {:ok, %Template{}} <- Templates.delete_template(template) do
      send_resp(conn, :no_content, "")
    else
      error ->
        Logger.error("While deleting template... #{inspect(error)}")

        conn
        |> put_status(:unprocessable_entity)
        |> render(ErrorView, :"422.json")
    end
  end

  defp format_preprocess_params(%{domain_id: nil} = raw_params) do
    raw_params |> Map.delete(:domain_id)
  end

  defp format_preprocess_params(raw_params), do: raw_params
end
