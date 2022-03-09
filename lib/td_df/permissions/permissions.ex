defmodule TdDf.Permissions do
  @moduledoc """
  The Permissions context.
  """

  alias TdDf.Auth.Claims

  def authorized?(%Claims{jti: jti}, permission, domain_id) do
    TdCache.Permissions.has_permission?(jti, permission, "domain", domain_id)
  end

  def authorized?(_, _, _), do: false
end
