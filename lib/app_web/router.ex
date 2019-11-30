defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/google/auth/callback", GoogleAuthController, :index

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
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end
end
