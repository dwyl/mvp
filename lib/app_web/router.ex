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

  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :index

    # create liveview endpoint:
    

    resources "/tags", TagController
    resources "/status", StatusController
    resources "/people", PersonController
    resources "/items", ItemController
    resources "/lists", ListController
    resources "/timers", TimerController
  end
end
