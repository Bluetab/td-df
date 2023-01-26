defmodule TdDfWeb.Router do
  use TdDfWeb, :router

  pipeline :api do
    plug TdDf.Auth.Pipeline.Unsecure
    plug TdDfWeb.Locale
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug TdDf.Auth.Pipeline.Secure
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :td_df, swagger_file: "swagger.json"
  end

  scope "/api", TdDfWeb do
    pipe_through :api
    get "/ping", PingController, :ping
    post "/echo", EchoController, :echo
  end

  scope "/api", TdDfWeb do
    pipe_through [:api, :api_auth]

    resources "/hierarchies", HierarchyController

    resources "/templates", TemplateController, except: [:new, :edit]
  end

  def swagger_info do
    %{
      schemes: ["http", "https"],
      info: %{
        version: Application.spec(:td_df, :vsn),
        title: "Truedat Dynamic Forms Service"
      },
      securityDefinitions: %{
        bearer: %{
          type: "apiKey",
          name: "Authorization",
          in: "header"
        }
      },
      security: [
        %{
          bearer: []
        }
      ]
    }
  end
end
