defmodule TdDfWeb.ChangesetView do
  use TdDfWeb, :view
  import TdDfWeb.ChangesetSupport

  def render("error.json", %{changeset: changeset, prefix: prefix}) do
    %{errors: translate_errors(changeset, prefix)}
  end

  def render("error.json", %{changeset: changeset}) do
    %{errors: translate_errors(changeset)}
  end
end
