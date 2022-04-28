defmodule TdDf.Canada.Abilities do
  @moduledoc false
  alias TdDf.Auth.Claims

  defimpl Canada.Can, for: Claims do
    def can?(%Claims{role: "admin"}, _action, _domain), do: true
    def can?(%Claims{role: "service"}, _action, _domain), do: true

    def can?(%Claims{}, _action, _domain), do: false
  end
end
