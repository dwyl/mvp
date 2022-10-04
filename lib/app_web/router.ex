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

  # No Auth
  scope "/", AppWeb do
    pipe_through :browser
    get "/init", InitController, :index
  end

  pipeline :authOptional, do: plug(AuthPlugOptional)

  scope "/", AppWeb do
    pipe_through [:browser, :authOptional]

    live "/", AppLive
    resources "/tags", TagController, except: [:show]
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
    resources "/profile", ProfileController, except: [:index, :delete]
  end
end
