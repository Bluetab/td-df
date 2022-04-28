defmodule TdDf.Templates.FieldFormatter do
  @moduledoc """
  Module for format template fields
  """
  alias TdDf.Permissions

  def format(%{"name" => "_confidential"} = field, ctx) do
    field
    |> Map.put("type", "string")
    |> Map.put("widget", "checkbox")
    |> Map.put("cardinality", "?")
    |> Map.put("default", "No")
    |> Map.put("disabled", is_confidential_field_disabled?(ctx))
  end

  def format(%{"type" => "user", "values" => %{"role_users" => role_name}} = field, ctx) do
    claims = Map.get(ctx, :claims, nil)
    user_roles = Map.get(ctx, :user_roles, %{})
    apply_role_meta(field, claims, role_name, user_roles)
  end

  def format(%{} = field, _ctx), do: field

  defp is_confidential_field_disabled?(%{claims: %{role: "admin"}}), do: false

  defp is_confidential_field_disabled?(%{domain_id: domain_id, claims: claims}) do
    !Permissions.authorized?(claims, :manage_confidential_business_concepts, domain_id)
  end

  defp is_confidential_field_disabled?(_), do: true

  defp apply_role_meta(
         %{"values" => values} = field,
         %{user_id: user_id} = _claims,
         role_name,
         user_roles
       )
       when not is_nil(role_name) do
    users = Map.get(user_roles, role_name, [])
    usernames = Enum.map(users, & &1.full_name)
    values = Map.put(values, "processed_users", usernames)
    field = Map.put(field, "values", values)

    case Enum.find(users, &(&1.id == user_id)) do
      nil -> field
      u -> Map.put(field, "default", u.full_name)
    end
  end

  defp apply_role_meta(field, _claims, _role, _user_roles), do: field
end
