defmodule AppWeb.ProfileController do
  use AppWeb, :controller
  alias App.Person
  plug :loggedin
  plug :permission_profile when action in [:show, :edit, :update]

  def show(conn, %{"id" => person_id}) do
    person = Person.get_person!(person_id)

    render(conn, "show.html", person: person)
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

    if String.to_integer(conn.params["id"]) == person_id do
      conn
    else
      conn
      |> put_flash(:info, "You can't access that page")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
