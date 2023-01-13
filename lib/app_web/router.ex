defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AppWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  # No Auth
  scope "/", AppWeb do
    pipe_through :browser
    get "/init", InitController, :index
    get "/login", AuthController, :login
  end

  pipeline :authOptional do
    plug(AuthPlugOptional)
  end

  scope "/", AppWeb do
    pipe_through [:browser, :authOptional]
    live "/", AppLive
    get "/logout", AuthController, :logout
    live "/stats", StatsLive
    resources "/tags", TagController, except: [:show]
  end

  scope "/api", AppWeb do
    pipe_through [:api, :authOptional]

    resources "/items", API.ItemController, only: [:create, :update, :show]

    resources "/items/:item_id/timers", API.TimerController,
      only: [:create, :update, :show, :index]

    resources "/tags", API.TagController, only: [:create, :update, :show]
  end
end
