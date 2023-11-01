defmodule TdDf.Templates do
  @moduledoc """
  The Templates context.
  """

  import Ecto.Query, warn: false

  alias TdDf.Cache.TemplateLoader
  alias TdDf.Repo
  alias TdDf.Templates.Template

  def list_templates(params \\ %{}) do
    template_fields = Template.__schema__(:fields)
    where_clause = filter(params, template_fields)

    Repo.all(
      from(p in Template,
        where: ^where_clause
      )
    )
  end

  def list_templates_by_scope(scope) do
    Template
    |> where(scope: ^scope)
    |> Repo.all()
  end

  def get_template!(id), do: Repo.get!(Template, id)

  def get_template(id), do: Repo.get(Template, id)

  def get_template_by_name!(name), do: Repo.get_by!(Template, name: name)

  def create_template(params \\ %{}) do
    %Template{}
    |> Template.changeset(params)
    |> Repo.insert()
    |> refresh_cache()
  end

  def update_template(%Template{} = template, params) do
    template
    |> Template.update_changeset(params)
    |> Repo.update()
    |> refresh_cache()
  end

  def delete_template(%Template{} = template) do
    template
    |> Repo.delete()
    |> clean_cache()
  end

  def refresh_cache({:ok, %{id: id}} = response) do
    TemplateLoader.refresh(id)
    response
  end

  def refresh_cache(response), do: response

  defp clean_cache({:ok, %{id: id}} = response) do
    TemplateLoader.delete(id)
    response
  end

  defp clean_cache(response), do: response

  @doc """
  Filter list by the given params
  """
  def filter(params, fields) do
    dynamic = true

    Enum.reduce(Map.keys(params), dynamic, fn key, acc ->
      key_as_atom = if is_binary(key), do: String.to_atom(key), else: key

      case Enum.member?(fields, key_as_atom) do
        true -> filter_by_type(key_as_atom, params[key], acc)
        false -> acc
      end
    end)
  end

  defp filter_by_type(atom_key, param_values, acc) when is_list(param_values) do
    dynamic([p], field(p, ^atom_key) in ^param_values and ^acc)
  end

  defp filter_by_type(atom_key, param_value, acc) do
    dynamic([p], field(p, ^atom_key) == ^param_value and ^acc)
  end
end
