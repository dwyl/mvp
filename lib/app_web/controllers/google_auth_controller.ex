defmodule AppWeb.GoogleAuthController do
  use AppWeb, :controller
  alias App.Ctx.Session
  alias App.Repo

  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token["access_token"])
    IO.inspect profile, label: "profile"
    # get the person by email
    case App.Ctx.get_person_by_email(profile["email"]) do
      nil ->
        # Create the person
        {:ok, google_person} = App.Ctx.create_google_person(profile)

        # Create session
        session_attrs = %{
          "auth_token" => token["access_token"],
          "refresh_token" => token["refresh_token"]
        }

        App.Ctx.create_session(google_person, session_attrs)

      person ->
        # create new session and
        session_attrs = %{
          "auth_token" => token["access_token"],
          "refresh_token" => "dummy_refresh_token", # we don't need refresh for now.
        }

        App.Ctx.create_session(person, session_attrs)

    end

    redirect(conn, to: "/")
  end

  @doc """
  `transform_profile_data_to_person/1` transforms the profile data 
  received from invoking `ElixirAuthGoogle.get_user_profile/1`
  into a `person` record that can be inserted into the database.

  ## Example

    iex> transform_profile_data_to_person(%{
      "email" => "nelson@gmail.com",
      "email_verified" => true,
      "family_name" => "Correia",
      "given_name" => "Nelson",
      "locale" => "en",
      "name" => "Nelson Correia",
      "picture" => "https://lh3.googleusercontent.com/a-/AAuE7mApnYb260YC1JY7",
      "sub" => "940732358705212133793"
    })
    %{
      "email" => "nelson@gmail.com",
      "status" => 1,
      "familyName" => "Correia",
      "givenName" => "Nelson",
    }
  """
  def transform_profile_data_to_person(proflie) do
    %{
      "email" => Map.get(profile, :email),
      "status" => 1,
      "familyName" => Map.get(profile, :family_name),
      "givenName" => Map.get(profile, :given_name),
    }
  end

end
