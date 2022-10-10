defmodule AppWeb.GroupController do
  use AppWeb, :controller
  alias App.{Group, Person}
  # plug :permission_tag when action in [:edit, :update, :delete]

  # Only member of the group can have persmission on the group updates
  # When a new group is created the person_id is added automatically in the group
  # Create the post /group/1/person/create endpoint to add a new person to the group by name

  # input text with person's name: --- Add to group
  # display list of existing group member
  # add liveview to not have to reload the page (nice to have)

  def index(conn, _params) do
    person_id = conn.assigns[:person][:id] || 0
    person = Person.get_person_with_groups!(person_id)

    render(conn, "index.html", groups: person.groups)
  end

  def new(conn, _params) do
    changeset = Group.changeset(%Group{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"group" => group_params}) do
    person_id = conn.assigns[:person][:id] || 0
    # add person_id to group

    case Group.create_group(person_id, group_params) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: Routes.group_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    group = Group.get_group!(id)
    changeset = Group.changeset(group)
    render(conn, "edit.html", group: group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Group.get_group!(id)

    case Group.update_group(group, group_params) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: Routes.group_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Group.get_group!(id)
    {:ok, _group} = Group.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: Routes.group_path(conn, :index))
  end
end
