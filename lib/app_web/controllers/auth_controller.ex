defmodule AppWeb.Auth do
  use AppWeb, :controller
  # use AppWeb, :router
  alias AppWeb.Router.Helpers
  alias App.Ctx.Session
  import Plug.Conn
  # alias App.Repo

  def init(opts), do: opts

  def call(conn, _opts) do
    person_id = get_session(conn, :person_id)

    cond do
      person = conn.assigns[:current_person] ->
        assign(conn, :current_person, person)

      person = person_id && App.Ctx.get_person!(person_id) ->
        assign(conn, :current_person, person)

      true ->
        assign(conn, :current_person, nil)
    end
  end

  def login(conn, person) do
    conn
    |> assign(:current_person, person)
    |> put_session(:person_id, person.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end


  def authenticate_person(conn, _opts) do
    if conn.assigns.current_person do
      conn
    else
      conn
      # redirect to login page
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
