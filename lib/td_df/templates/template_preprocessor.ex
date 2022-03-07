defmodule TdDf.Templates.Preprocessor do
  @moduledoc false

  alias TdDf.AclLoader
  alias TdDf.Templates.FieldFormatter

  def preprocess_template(template, context \\ %{})

  def preprocess_template(template, %{domain_id: domain_id} = context) do
    user_roles = AclLoader.get_roles_and_users(domain_id)

    context = Map.put(context, :user_roles, user_roles)

    preprocess_template_content(template, context)
  end

  def preprocess_template(template, context) do
    preprocess_template_content(template, context)
  end

  defp preprocess_template_content(%{content: content} = template, context) do
    content =
      Enum.map(content, fn %{"fields" => fields} = group ->
        fields = Enum.map(fields, &FieldFormatter.format(&1, context))
        %{group | "fields" => fields}
      end)

    %{template | content: content}
  end
end
