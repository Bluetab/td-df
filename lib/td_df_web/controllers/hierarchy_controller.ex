defmodule TdDfWeb.HierarchyController do
  use TdDfWeb, :controller

  import Canada, only: [can?: 2]

  alias TdDf.Hierarchies

  action_fallback(TdDfWeb.FallbackController)

  def index(conn, _params) do
    claims = conn.assigns[:current_resource]

    with {:can, true} <- {:can, can?(claims, index([]))},
         hierarchies <- Hierarchies.list_hierarchies() do
      render(conn, "index.json", hierarchies: hierarchies)
    end
  end

  def create(conn, %{"hierarchy" => hierarchy}) do
    claims = conn.assigns[:current_resource]

    with {:can, true} <- {:can, can?(claims, manage(hierarchy))},
         {:ok, %{id: id}} <- Hierarchies.create_hierarchy(hierarchy),
         hierarchy <- Hierarchies.get_hierarchy!(id) do
      conn
      |> put_status(:created)
      |> render("show.json", hierarchy: hierarchy)
    end
  end

  def show(conn, %{"id" => id}) do
    with %{} = hierarchy <- Hierarchies.get_hierarchy!(id) do
      render(conn, "show.json", hierarchy: hierarchy)
    end
  end

  def update(conn, %{"id" => id, "hierarchy" => hierarchy_params}) do
    claims = conn.assigns[:current_resource]
    hierarchy = Hierarchies.get_hierarchy!(id)

    with {:can, true} <- {:can, can?(claims, manage(hierarchy))},
         {:ok, %{id: id}} <- Hierarchies.update_hierarchy(hierarchy, hierarchy_params),
         hierarchy <- Hierarchies.get_hierarchy!(id) do
      render(conn, "show.json", hierarchy: hierarchy)
    end
  end

  def delete(conn, %{"id" => id}) do
    claims = conn.assigns[:current_resource]
    hierarchy = Hierarchies.get_hierarchy!(id)

    with {:can, true} <- {:can, can?(claims, manage(hierarchy))},
         {:ok, %{}} <- Hierarchies.delete_hierarchy(hierarchy) do
      send_resp(conn, :no_content, "")
    end
  end
end
