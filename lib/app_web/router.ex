defmodule AppWeb.Router do
  use AppWeb, :router
  alias App.Person

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
  pipeline :check_profile_name, do: plug(:profile_name)

  scope "/", AppWeb do
    pipe_through [:browser, :authOptional, :verify_loggedin]

    resources "/profile", ProfileController,
      only: [:edit, :update],
      param: "person_id"

    pipe_through [:check_profile_name]
    live "/", AppLive
    resources "/tags", TagController, except: [:show]
    resources "/lists", ListController, except: [:show]
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout

    # edit item lists
    resources "/items", ItemController, only: [:edit, :update]

    # manage groups
    resources "/groups", GroupController, except: [:show]

    # edit and update group members
    resources "/groups", GroupController, only: [:show] do
      resources "/members", GroupMemberController, only: [:index, :create]
      resources "/lists", GroupListController, only: [:index, :create]
    end
  end

  # assign to conn the loggedin value used in templates
  defp loggedin(conn, _opts) do
    if not is_nil(conn.assigns[:jwt]) do
      assign(conn, :loggedin, true)
    else
      assign(conn, :loggedin, false)
    end
  end

  # Redirect to edit profile to force user to
  # add name to their profile for sharing items feature
  defp profile_name(conn, _opts) do
    person_id = conn.assigns[:person][:id] || 0

    person = Person.get_or_insert(person_id)

    if is_nil(person.name) do
      conn
      |> put_flash(:info, "Add a name to your profile to allow sharing items")
      |> redirect(to: "/profile/#{person.person_id}/edit")
      |> halt()
    else
      conn
    end
  end
end
