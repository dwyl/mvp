defmodule AppWeb.GoogleAuthController do
  use AppWeb, :controller

  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token["access_token"])

    # get the person by email
    case App.Ctx.get_person_by_email(profile["email"]) do
      nil ->
        # Create the person
        google_person = App.Ctx.create_google_person(profile)
        # Create session


      person ->
        # update token
        IO.inspect "update token"
    end

    redirect(conn, to: "/")
  end
end
