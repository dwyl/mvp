defmodule AppWeb.GoogleAuthController do
  use AppWeb, :controller
  alias App.Ctx.Session
  alias App.Repo

  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token["access_token"])
    # get the person by email
    case App.Ctx.get_person_by_email(profile["email"]) do
      nil ->
        # Create the person
        {:ok, google_person} = App.Ctx.create_google_person(profile)

        # Create session
        session_attrs = %{"auth_token" => token["access_token"],
                    "refresh_token" => token["refresh_token"]
                   }

        App.Ctx.create_session(google_person, session_attrs)

      person ->
        # create new session and
        session_attrs = %{"auth_token" => token["access_token"],
                    "refresh_token" => "dummy_refresh_token",
                   }


        App.Ctx.create_session(person, session_attrs)

    end

    redirect(conn, to: "/")
  end
end
