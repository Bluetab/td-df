defmodule TdDfWeb.PingController do
  use TdDfWeb, :controller

  action_fallback TdDfWeb.FallbackController

  def ping(conn, _params) do
    send_resp(conn, 200, "pong")
  end
end
