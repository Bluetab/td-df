defmodule TdDf.AclLoader do
  @moduledoc """
  The Permissions context.
  """

  @acl_cache_resolver Application.get_env(:td_df, :acl_cache_resolver)
  @user_cache_resolver Application.get_env(:td_df, :user_cache_resolver)
  @taxonomy_cache_resolver Application.get_env(:td_df, :taxonomy_cache_resolver)

  def get_roles_and_users(r_type, r_id) do
    r_id
    |> @taxonomy_cache_resolver.get_parent_ids(true)
    |> Enum.map(fn d_id -> {d_id, @acl_cache_resolver.get_acl_roles(r_type, d_id)} end)
    |> Enum.reduce([], fn {d_id, roles}, acc -> acc ++ fetch_users_by_role(d_id, r_type, roles) end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {role, users} -> {role, flatten_user_list(users)} end)
    |> Enum.into(%{})
  end

  def fetch_users_by_role(d_id, r_type, roles) do
    roles
      |> Enum.map(fn role ->
        users = r_type
        |> @acl_cache_resolver.get_acl_role_users(d_id, role)
        |> Enum.map(fn user_id ->
            user_id
            |> @user_cache_resolver.get_user
            |> Map.take([:full_name])
            |> Map.put(:id, String.to_integer(user_id))
          end)
        {role, users}
      end)
  end

  defp flatten_user_list(users) do
    users |> List.flatten() |> Enum.uniq_by(& &1.id)
  end
end
