defmodule TdDf.Auth.Pipeline.Unsecure do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :td_df,
    error_handler: TdDf.Auth.ErrorHandler,
    module: TdDf.Auth.Guardian

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.LoadResource, allow_blank: true
end
