defmodule TdDf.Auth.Pipeline.Secure do
  @moduledoc """
  Plug pipeline for routes requiring authentication
  """

  use Guardian.Plug.Pipeline,
    otp_app: :td_df,
    error_handler: TdDf.Auth.ErrorHandler,
    module: TdDf.Auth.Guardian

  plug Guardian.Plug.EnsureAuthenticated, claims: %{"aud" => "truedat", "iss" => "tdauth"}
  plug Guardian.Plug.LoadResource
  plug TdDf.Auth.Plug.SessionExists
  plug TdDf.Auth.Plug.CurrentResource
end
