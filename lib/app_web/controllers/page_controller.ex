defmodule AppWeb.PageController do
  use AppWeb, :controller
  alias App.Ctx.Person

  # auth_controller assign current_person on each request
  # when the person is loggedin, otherwise the value doesn't exists or is nil
  def index(%{assigns: %{current_person: person}} = conn, _params) when not is_nil(person) do
    redirect(conn, to: Routes.person_path(conn, :info))
  end

  def index(conn, _params) do
    url_oauth_google = ElixirAuthGoogle.generate_oauth_url(conn)
    changeset = Person.changeset_registration(%Person{}, %{})
    render(conn, "index.html",
      [url_oauth_google: url_oauth_google, person: %{}, changeset: changeset])
  end
end

