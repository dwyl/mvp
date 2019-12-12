defmodule AppWeb.GoogleAuthController do
  use AppWeb, :controller

  @elixir_auth_google Application.get_env(:app, :elixir_auth_google) || ElixirAuthGoogle

  def index(conn, %{"code" => code}) do
    {:ok, token} = @elixir_auth_google.get_token(code, conn)
    {:ok, profile} = @elixir_auth_google.get_user_profile(token.access_token)
    person = App.Ctx.Person.transform_profile_data_to_person(profile)

    # get the person by email
    case App.Ctx.get_person_by_email(person.email) do
      nil ->
        # Create the person
        {:ok, person} = App.Ctx.create_google_person(person)
        create_session(conn, person, token)

      person ->
        create_session(conn, person, token)
    end
  end

  def create_session(conn, person, token) do
    # Create session
    session_attrs = %{
      "auth_token" => token.access_token,
      "refresh_token" =>
        if Map.has_key?(token, :refresh_token) do
          token.refresh_token
        else
          nil
        end
    }

    App.Ctx.create_session(person, session_attrs)

    # login and redirect to welcome page:
    AppWeb.Auth.login(conn, person)
    |> redirect(to: Routes.person_path(conn, :info))
  end
end
