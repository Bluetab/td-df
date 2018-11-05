defmodule TdDfWeb.AclEntry do
  @moduledoc false

  alias TdDf.Permissions.MockPermissionResolver

  def acl_entry_create(_token, acl_entry_params) do
    MockPermissionResolver.create_acl_entry(acl_entry_params)
    {:ok, 200, %{}}
  end

end
