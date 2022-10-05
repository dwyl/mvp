defmodule AppWeb.ProfileController do
  use AppWeb, :controller
  alias App.Person
  plug :permission_profile when action in [:edit, :update]

  def edit(conn, %{"person_id" => person_id}) do
    profile = Person.get_person!(person_id)
    changeset = Person.changeset(profile)
    render(conn, "edit.html", profile: profile, changeset: changeset)
  end

  def update(
        conn,
        %{"person_id" => person_id, "person" => person_params}
      ) do
    profile = Person.get_person!(person_id)

    case Person.update_person(profile, person_params) do
      {:ok, _person} ->
        conn
        |> put_flash(:info, "Person updated successfully.")
        |> redirect(to: "/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", profile: profile, changeset: changeset)
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
