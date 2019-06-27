defmodule TdDf.AclLoader do
  @moduledoc """
  The Permissions context.
  """

  alias TdCache.AclCache
  alias TdCache.TaxonomyCache
  alias TdCache.UserCache

  def get_roles_and_users(r_type, r_id) do
    r_id
    |> TaxonomyCache.get_parent_ids()
    |> Enum.map(fn d_id -> {d_id, AclCache.get_acl_roles(r_type, d_id)} end)
    |> Enum.reduce([], fn {d_id, roles}, acc ->
      acc ++ fetch_users_by_role(d_id, r_type, roles)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.into(%{}, fn {role, users} -> {role, flatten_user_list(users)} end)
  end

  def fetch_users_by_role(d_id, r_type, roles) do
    roles
    |> Enum.map(fn role ->
      users =
        r_type
        |> get_user_by_resource_and_role(d_id, role)
        |> Enum.filter(&(!is_nil(&1)))

      {role, users}
    end)
  end

  defp get_user_by_resource_and_role(resource_type, resource_id, role) do
    resource_type
    |> AclCache.get_acl_role_users(resource_id, role)
    |> Enum.map(fn user_id ->
      case UserCache.get(user_id) do
        {:ok, nil} ->
          nil

        {:ok, user} ->
          user
          |> Map.take([:id, :full_name])
      end
    end)
  end

  defp flatten_user_list(users) do
    users |> List.flatten() |> Enum.uniq_by(& &1.id)
  end
end
