defmodule TdDfWeb.Router do
  use TdDfWeb, :router

  @endpoint_url "#{Application.get_env(:td_df, TdDfWeb.Endpoint)[:url][:host]}:#{Application.get_env(:td_df, TdDfWeb.Endpoint)[:url][:port]}"

  pipeline :api do
    plug TdDf.Auth.Pipeline.Unsecure
    plug TdDfWeb.Locale
    plug :accepts, ["json"]
  end

  pipeline :api_secure do
    plug TdDf.Auth.Pipeline.Secure
  end

  pipeline :api_authorized do
    plug TdDf.Auth.CurrentUser
    plug Guardian.Plug.LoadResource
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :td_df, swagger_file: "swagger.json"
  end

  scope "/api", TdDfWeb do
    pipe_through :api
    get  "/ping", PingController, :ping
    post "/echo", EchoController, :echo
  end

  scope "/api", TdDfWeb do
    pipe_through [:api, :api_secure, :api_authorized]
    
    resources "/templates", TemplateController, except: [:new, :edit]
    get "/templates/load/:id", TemplateController, :load_and_show

    get "/template_relations/related_templates", TemplateRelationController, :get_related_templates
    resources "/template_relations", TemplateRelationController, except: [:new, :edit]
  end

  def swagger_info do
    %{
      schemes: ["http"],
      info: %{
        version: "1.0",
        title: "TdDf"
      },
      host: @endpoint_url,
      #"basePath": "/api",
      securityDefinitions:
        %{
          bearer:
          %{
            type: "apiKey",
            name: "Authorization",
            in: "header",
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
