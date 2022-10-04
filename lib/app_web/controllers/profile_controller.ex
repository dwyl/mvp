defmodule AppWeb.ProfileController do
  use AppWeb, :controller
  alias App.Person
  plug :loggedin
  plug :permission_profile when action in [:show, :edit, :update]

  def show(conn, %{"personid" => person_id}) do
    profile = Person.get_person!(person_id)

    render(conn, "show.html", profile: profile)
  end

  def edit(conn, %{"person_id" => person_id}) do
    profile = Person.get_person!(person_id)
    changeset = Person.changeset(profile)
    render(conn, "edit.html", profile: profile, changeset: changeset)
  end

  defp loggedin(conn, _opts) do
    if not is_nil(conn.assigns[:jwt]) do
      assign(conn, :loggedin, true)
    else
      assign(conn, :loggedin, false)
    end
  end

  defp permission_profile(conn, _opts) do
    person_id = conn.assigns[:person][:id] || 0

    if String.to_integer(conn.params["person_id"]) == person_id do
      conn
    else
      conn
      |> put_flash(:info, "You can't access that page")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
