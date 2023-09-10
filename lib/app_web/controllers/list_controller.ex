defmodule AppWeb.ListController do
  use AppWeb, :controller
  alias App.List
  plug :permission_list when action in [:edit, :update, :delete]

  def index(conn, _params) do
    person_id = conn.assigns[:person][:id] || 0
    lists = List.get_lists_for_person(person_id)

    render(conn, "index.html", lists: lists)
  end

  def new(conn, _params) do
    changeset = List.changeset(%List{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"list" => list_params}) do
    person_id = conn.assigns[:person][:id] || 0
    list_params = Map.put(list_params, "person_id", person_id)

    case List.create_list(list_params) do
      {:ok, _list} ->
        conn
        |> put_flash(:info, "List created successfully.")
        |> redirect(to: Routes.list_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    list = List.get_list!(id)
    changeset = List.changeset(list)
    render(conn, "edit.html", list: list, changeset: changeset)
  end

  def update(conn, %{"id" => id, "list" => list_params}) do
    list = List.get_list!(id)

    case List.update_list(list, list_params) do
      {:ok, _list} ->
        conn
        |> put_flash(:info, "List updated successfully.")
        |> redirect(to: Routes.list_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", list: list, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    list = List.get_list!(id)
    {:ok, _list} = List.delete_list(list.id)

    conn
    |> put_flash(:info, "list deleted successfully.")
    |> redirect(to: Routes.list_path(conn, :index))
  end

  defp permission_list(conn, _opts) do
    list = List.get_list!(conn.params["id"])
    person_id = conn.assigns[:person][:id] || 0

    if list.person_id == person_id do
      conn
    else
      conn
      |> put_flash(:info, "You can't access that page")
      |> redirect(to: "/lists")
      |> halt()
    end
  end
end
