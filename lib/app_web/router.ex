defmodule AppWeb.Router do
  use AppWeb, :router
  import AppWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AppWeb.Auth
  end

  pipeline :api do
    plug CORSPlug,
      origin:
        System.get_env("ALLOW_API_ORIGINS")
        |> String.replace("'", "")
        |> String.split(",")

    plug :accepts, ["json"]
  end

  pipeline :auth_optional, do: plug(AuthPlugOptional, %{})

  scope "/", AppWeb do
    pipe_through [:browser, :auth_optional]

    get "/", PageController, :index
    post "/register", PageController, :register
    get "/auth/google/callback", GoogleAuthController, :index
  end

  pipeline :auth, do: plug(AuthPlug, %{auth_url: "https://dwylauth.herokuapp.com"})

  scope "/", AppWeb do
    pipe_through [:browser, :auth]

    # person information
    get "/people/info", PersonController, :info
    get "/people/logout", PersonController, :logout

    # generic resources for schemas:
    resources "/items", ItemController
    resources "/lists", ListController
    resources "/people", PersonController
    resources "/status", StatusController
    resources "/tags", TagController
    resources "/timers", TimerController

    # capture
    resources "/capture", CaptureController, only: [:new, :create]

    # categorise
    resources "/categorise", CategoriseController, only: [:index]
  end

  # Other scopes may use custom stacks.
  scope "/api", AppWeb do
    pipe_through :api

    post "/captures/create", CaptureController, :api_create
    options "/captures/create", CaptureController, :api_create
    get "/items", ItemController, :api_index
    options "/items", ItemController, :api_index
  end
end
