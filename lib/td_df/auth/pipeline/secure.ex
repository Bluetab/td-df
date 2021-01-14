defmodule TdDf.Auth.Pipeline.Secure do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :td_df,
    error_handler: TdDf.Auth.ErrorHandler,
    module: TdDf.Auth.Guardian

  plug Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "access"}

  # Assign :current_resource to connection
  plug TdDf.Auth.CurrentResource
end
