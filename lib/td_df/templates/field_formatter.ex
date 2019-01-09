defmodule TdDf.Templates.FieldFormatter do
  @moduledoc """
  Module for format template fields
  """
  alias TdDf.Permissions

  def format(%{"name" => "_confidential"} = field, ctx) do
    field
    |> Map.put("type", "list")
    |> Map.put("widget", "checkbox")
    |> Map.put("required", false)
    |> Map.put("values", ["Si", "No"])
    |> Map.put("default", "No")
    |> Map.put("disabled", is_confidential_field_disabled?(ctx))
    |> Map.delete("meta")
  end

  def format(%{"type" => "list", "meta" => %{"role" => role_name}} = field, ctx) do
    user = Map.get(ctx, :user, nil)
    user_roles = Map.get(ctx, :user_roles, [])
    field
    |> apply_role_meta(user, role_name, user_roles)
    |> Map.delete("meta")
  end

  def format(%{"type" => _type, "meta" => _meta} = field, _ctx) do
    field
    |> Map.delete("meta")
  end

  def format(%{} = field, _ctx), do: field

  defp is_confidential_field_disabled?(%{user: %{is_admin: true}}), do: false

  defp is_confidential_field_disabled?(%{domain_id: domain_id, user: user}) do
    !Permissions.authorized?(user, :manage_confidential_business_concepts, domain_id)
  end

  defp is_confidential_field_disabled?(_), do: true

  defp apply_role_meta(%{} = field, user, role_name, user_roles)
       when not is_nil(user) and not is_nil(role_name) do
    users = Map.get(user_roles, role_name, [])

    usernames =
      users
      |> Enum.map(& &1.full_name)

    field = Map.put(field, "values", usernames)

    case Enum.find(users, &(&1.id == user.id)) do
      nil -> field
      u -> Map.put(field, "default", u.full_name)
    end
  end

  defp apply_role_meta(field, _user, _role, _user_roles), do: field
end
