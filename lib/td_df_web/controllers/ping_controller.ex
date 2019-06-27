defmodule TdDfWeb.EchoController do
  use TdDfWeb, :controller

  alias Jason, as: JSON

  action_fallback TdDfWeb.FallbackController

  def echo(conn, params) do
    send_resp(conn, 200, params |> JSON.encode!())
  end
end
