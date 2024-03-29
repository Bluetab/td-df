defmodule CacheHelpers do
  @moduledoc """
  Helper functions for loading and cleaning test fixtures in cache
  """

  import ExUnit.Callbacks, only: [on_exit: 1]
  import TdDf.Factory

  alias TdCache.AclCache
  alias TdCache.TaxonomyCache
  alias TdCache.UserCache

  def put_acl_role_users(domain_id, role, users_or_user_ids) do
    user_ids =
      Enum.map(users_or_user_ids, fn
        %{id: id} -> id
        id when is_integer(id) -> id
      end)

    on_exit(fn ->
      AclCache.delete_acl_roles("domain", domain_id)
      AclCache.delete_acl_role_users("domain", domain_id, role)
    end)

    AclCache.set_acl_roles("domain", domain_id, [role])
    AclCache.set_acl_role_users("domain", domain_id, role, user_ids)
  end

  def put_acl_role_users_and_groups(domain_id, role, user_ids, group_ids) do
    on_exit(fn ->
      AclCache.delete_acl_roles("domain", domain_id)
      AclCache.delete_acl_group_roles("domain", domain_id)
      AclCache.delete_acl_role_users("domain", domain_id, role)
      AclCache.delete_acl_role_groups("domain", domain_id, role)
    end)

    AclCache.set_acl_roles("domain", domain_id, [role])
    AclCache.set_acl_group_roles("domain", domain_id, [role])
    AclCache.set_acl_role_users("domain", domain_id, role, user_ids)
    AclCache.set_acl_role_groups("domain", domain_id, role, group_ids)
  end

  def put_domain(params \\ %{})

  def put_domain(%{id: id} = domain) do
    on_exit(fn -> TaxonomyCache.delete_domain(id, clean: true) end)
    {:ok, _} = TaxonomyCache.put_domain(domain)
    domain
  end

  def put_domain(params) do
    :domain
    |> build(params)
    |> put_domain()
  end

  def put_user(params \\ %{})

  def put_user(%{id: id} = user) do
    on_exit(fn -> UserCache.delete(id) end)
    {:ok, _} = UserCache.put(user)
    user
  end

  def put_user(params) do
    :user
    |> build(params)
    |> put_user()
  end

  def put_user_group(params \\ %{})

  def put_user_group(%{id: id} = user) do
    on_exit(fn -> UserCache.delete_group(id) end)
    {:ok, _} = UserCache.put_group(user)
    user
  end

  def put_user_group(params) do
    :group
    |> build(params)
    |> put_user_group()
  end
end
