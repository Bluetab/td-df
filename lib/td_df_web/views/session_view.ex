defmodule TdDfWeb.SessionView do
  use TdDfWeb, :view

  def render("show.json", %{token: token}) do
    %{token: token}
  end

end
