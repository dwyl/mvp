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
  pipeline :verify_loggedin, do: plug(:loggedin)

  scope "/", AppWeb do
    pipe_through [:browser, :authOptional, :verify_loggedin]

    live "/", AppLive
    resources "/tags", TagController, except: [:show]
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout

    resources "/profile", ProfileController,
      except: [:index, :delete],
      param: "person_id"
  end

  defp loggedin(conn, _opts) do
    if not is_nil(conn.assigns[:jwt]) do
      assign(conn, :loggedin, true)
    else
      assign(conn, :loggedin, false)
    end
  end
end
