defmodule TdDf.Templates.Preprocessor do
  @moduledoc false

  alias TdDf.AclLoader
  alias TdDf.Templates.FieldFormatter

  def preprocess_templates(templates, context \\ %{})

  def preprocess_templates(
        templates,
        %{resource_type: resource_type, resource_id: resource_id} = context
      ) do
    user_roles = AclLoader.get_roles_and_users(resource_type, resource_id)

    context =
      context
      |> Map.put(:user_roles, user_roles)
      |> Map.drop([:resource_type, :resource_id, :domain_id])

    templates
    |> Enum.map(&preprocess_template(&1, context))
  end

  def preprocess_templates(templates, context) do
    templates
    |> Enum.map(&preprocess_template(&1, context))
  end

  def preprocess_template(template, context \\ %{})

  def preprocess_template(template, %{domain_id: domain_id} = context) do
    user_roles = AclLoader.get_roles_and_users("domain", domain_id)

    context =
      context
      |> Map.put(:user_roles, user_roles)
      |> Map.delete(:domain_id)

    preprocess_template(template, context)
  end

  def preprocess_template(%{content: content} = template, context) do
    content =
      content
      |> Enum.map(&FieldFormatter.format(&1, context))

    template
    |> Map.put(:content, content)
  end
end
