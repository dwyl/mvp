defmodule AppWeb.PageController do
  use AppWeb, :controller
  alias App.Ctx.Person
  alias App.Ctx

  # auth_controller assign current_person on each request
  # when the person is loggedin, otherwise the value doesn't exists or is nil
  def index(%{assigns: %{current_person: person}} = conn, _params)
      when not is_nil(person) do
    redirect(conn, to: Routes.person_path(conn, :info))
  end

  def index(conn, _params) do
    url_oauth_google = ElixirAuthGoogle.generate_oauth_url(conn)
    changeset = Person.changeset_registration(%Person{}, %{})

    render(conn, "index.html",
      url_oauth_google: url_oauth_google,
      changeset: changeset
    )
  end

  def register(conn, %{"person" => person_params}) do
    person = Ctx.get_person_by_email(person_params["email"])

    # create new person
    # Login person if password ok
    if is_nil(person) do
      case Ctx.register_person(person_params) do
        {:ok, person} ->
          create_basic_session(conn, person)

        {:error, %Ecto.Changeset{} = changeset} ->
          url_oauth_google = ElixirAuthGoogle.generate_oauth_url(conn)

          render(conn, "index.html",
            url_oauth_google: url_oauth_google,
            changeset: changeset
          )
      end
    else
      login(conn, person, person_params)
    end
  end

  # verify provided password
  # create Phx session
  # and redirect to correct page:
  # user info page if password ok or index page if it doesn't match
  defp login(conn, person, person_params) do
    if Argon2.verify_pass(person_params["password"], person.password_hash) do
      create_basic_session(conn, person)
    else
      redirect(conn, to: Routes.page_path(conn, :index))
    end
  end

  # Insert a new basic session in Postgres
  defp create_basic_session(conn, person) do
    App.Ctx.create_basic_session(person, %{})

    AppWeb.Auth.login(conn, person)
    |> redirect(to: Routes.person_path(conn, :info))
  end
end
