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
end
