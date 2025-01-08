defmodule TdDfWeb.TemplateController do
  use TdDfWeb, :controller

  import Canada, only: [can?: 2]

  alias TdCache.Templates.Preprocessor
  alias TdDf.Templates
  alias TdDf.Templates.Template

  require Logger

  action_fallback(TdDfWeb.FallbackController)

  def index(conn, params) do
    templates = Templates.list_templates(params)
    render(conn, "index.json", templates: templates)
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

  def show(conn, %{"id" => id} = params) do
    claims = conn.assigns[:current_resource]

    with {:ok, domain_ids} <- domain_ids(params),
         %{} = template <- Templates.get_template!(id) do
      preprocess_params =
        case domain_ids do
          [_ | _] -> %{claims: claims, domain_ids: domain_ids}
          _ -> %{claims: claims}
        end

      template = Preprocessor.preprocess_template(template, preprocess_params)
      render(conn, "show.json", template: template)
    end
  end

  def update(conn, %{"id" => id, "template" => template_params}) do
    claims = conn.assigns[:current_resource]
    template = Templates.get_template!(id)

    with {:can, true} <- {:can, can?(claims, manage(template))},
         {:ok, %Template{} = template} <- Templates.update_template(template, template_params) do
      render(conn, "show.json", template: template)
    end
  end

  def delete(conn, %{"id" => id}) do
    claims = conn.assigns[:current_resource]
    template = Templates.get_template!(id)

    with {:can, true} <- {:can, can?(claims, manage(template))},
         {:ok, %Template{}} <- Templates.delete_template(template) do
      send_resp(conn, :no_content, "")
    end
  end

  defp domain_ids(%{"domain_id" => id}), do: domain_ids(id)
  defp domain_ids(%{"domain_ids" => ids}), do: domain_ids(ids)

  defp domain_ids(ids) when is_binary(ids) do
    {:ok, TdCache.Redix.to_integer_list!(ids)}
  rescue
    _ -> {:error, :unprocessable_entity}
  end

  defp domain_ids(_other), do: {:ok, []}
end
