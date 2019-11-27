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
        google_person = App.Ctx.create_google_person(profile)

        # Create session
        session = %{"auth_token" => token["access_token"],
                    "refresh_token" => token["refresh_token"]
                   }
        session_value = Ecto.build_assoc(google_person, :sessions, session)
        |> Repo.insert!()

        IO.inspect "create new person and session"
        IO.inspect session_value

      person ->
        # create new session and
        session = %{"auth_token" => token["access_token"],
                    "refresh_token" => "dummy_refresh_token"
                   }
        changeset = Session.changeset(%Session{}, session)
        Repo.insert(changeset)

        # session_value = Ecto.build_assoc(person, :sessions, changeset)
        # |> IO.inspect()
        # |> Repo.insert!()


    end

    redirect(conn, to: "/")
  end
end
