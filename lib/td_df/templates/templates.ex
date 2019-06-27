defmodule TdDf.Templates do
  @moduledoc """
  The Templates context.
  """

  import Ecto.Query, warn: false

  alias TdDf.Cache.TemplateLoader
  alias TdDf.Repo
  alias TdDf.Templates.Template

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates(attrs \\ %{}) do
    template_fields = Template.__schema__(:fields)
    where_clause = filter(attrs, template_fields)

    Repo.all(
      from(p in Template,
        where: ^where_clause
      )
    )
  end

  def list_templates_by_id(id_list) do
    Template
    |> where([t], t.id in ^id_list)
    |> Repo.all()
  end

  @doc """
  Gets a single template.

  Raises `Ecto.NoResultsError` if the Template does not exist.

  ## Examples

      iex> get_template!(123)
      %Template{}

      iex> get_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id), do: Repo.get!(Template, id)

  def get_template_by_name!(name) do
    Repo.one!(from(r in Template, where: r.name == ^name))
  end

  def get_template_by_name(name) do
    Repo.one(from(r in Template, where: r.name == ^name))
  end

  @doc """
  Creates a template.

  ## Examples

      iex> create_template(%{field: value})
      {:ok, %Template{}}

      iex> create_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template(attrs \\ %{}) do
    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
    |> refresh_cache
  end

  @doc """
  Updates a template.

  ## Examples

      iex> update_template(template, %{field: new_value})
      {:ok, %Template{}}

      iex> update_template(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
    |> refresh_cache
  end

  def update_template_no_cache(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Template.

  ## Examples

      iex> delete_template(template)
      {:ok, %Template{}}

      iex> delete_template(template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template(%Template{} = template) do
    template
    |> Repo.delete()
    |> clean_cache
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template changes.

  ## Examples

      iex> change_template(template)
      %Ecto.Changeset{source: %Template{}}

  """
  def change_template(%Template{} = template) do
    Template.changeset(template, %{})
  end

  defp refresh_cache({:ok, %{id: id}} = response) do
    TemplateLoader.refresh(id)
    response
  end

  defp refresh_cache(response), do: response

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
