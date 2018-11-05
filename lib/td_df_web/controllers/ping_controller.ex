defmodule TdDfWeb.EchoController do
  use TdDfWeb, :controller

  action_fallback TdDfWeb.FallbackController

  def echo(conn, params) do
    send_resp(conn, 200, params |> Poison.encode!)
  end
end
