defmodule AppWeb.PageController do
  use AppWeb, :controller
  alias App.Ctx.Person
  alias App.Ctx

  # auth_controller assign current_person on each request
  # when the person is loggedin, otherwise the value doesn't exists or is nil
  def index(%{assigns: %{current_person: person}} = conn, _params) when not is_nil(person) do
    redirect(conn, to: Routes.person_path(conn, :info))
  end

  def index(conn, _params) do
    url_oauth_google = ElixirAuthGoogle.generate_oauth_url(conn)
    changeset = Person.changeset_registration(%Person{}, %{})
    render(conn, "index.html",
      [url_oauth_google: url_oauth_google, changeset: changeset])
  end


  def register(conn, %{"person" => person_params}) do
    person = Ctx.get_person_by_email(person_params["email"])
    if is_nil(person) do #create new person
      url_oauth_google = ElixirAuthGoogle.generate_oauth_url(conn)
      case Ctx.register_person(person_params) do
        {:ok, person} ->
          AppWeb.Auth.login(conn, person)
          |> redirect(to: Routes.person_path(conn, :info))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "index.html",
            [url_oauth_google: url_oauth_google, changeset: changeset])
      end
    else #login existing person
      IO.inspect "logged in!!"
      # login and redirect to welcome page:
      AppWeb.Auth.login(conn, person)
      |> redirect(to: Routes.person_path(conn, :info))
    end
  end

end

