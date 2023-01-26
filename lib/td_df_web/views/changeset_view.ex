defmodule TdDfWeb.ChangesetView do
  use TdDfWeb, :view

  alias Ecto.Changeset
  alias TdDf.Hierarchies.Hierarchy
  import TdDfWeb.ChangesetSupport

  def render("error.json", %{changeset: changeset, prefix: prefix}) do
    %{errors: translate_errors(changeset, prefix)}
  end

  def render("error.json", %{changeset: %{data: %Hierarchy{}} = changeset}) do
    %{errors: Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  def render("error.json", %{changeset: changeset}) do
    %{errors: translate_errors(changeset)}
  end
end
