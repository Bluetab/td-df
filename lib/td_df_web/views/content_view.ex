defmodule TdDfWeb.ContentView do
  use TdDfWeb, :view
#  alias TdDfWeb.ContentView

  def render("errors.json", %{errors: errors}) do
    %{errors: errors}
  end
  
end
