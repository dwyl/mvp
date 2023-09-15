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

  defp downcase_name(list_params) do
    list_name = Map.get(list_params, "name") || nil

    if list_name != nil do
      Map.put(list_params, "name", String.downcase(list_name))
    else
      list_params
    end
  end

  def create(conn, %{"list" => list_params}) do
    dbg(list_params)
    person_id = conn.assigns[:person][:id] || 0

    list_params =
      downcase_name(list_params)
      |> Map.put("person_id", person_id)
      |> Map.put("status", 2)

    case List.create_list(list_params) do
      {:ok, _list} ->
        conn
        |> put_flash(:info, "List created successfully.")
        |> redirect(to: Routes.list_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # TODO: need to ensure we are checking for the person_id before editing
  # Should return 404 if person_id is not valid for this list.
  def edit(conn, %{"id" => id}) do
    list = List.get_list!(id)
    changeset = List.changeset(list)
    render(conn, "edit.html", list: list, changeset: changeset)
  end

  def update(conn, %{"id" => id, "list" => list_params}) do
    list = List.get_list!(id)
    list_params = downcase_name(list_params)

    case List.update_list(list, list_params) do
      {:ok, _list} ->
        conn
        |> put_flash(:info, "List updated successfully.")
        |> redirect(to: Routes.list_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", list: list, changeset: changeset)
    end
  end

  #  TODO: MUST check person_id matches before allowing "delete"!
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

    if list.person_id == person_id && list.name != "all" do
      conn
    else
      conn
      |> put_flash(:info, "You can't access that page")
      |> redirect(to: "/lists")
      |> halt()
    end
  end
end
