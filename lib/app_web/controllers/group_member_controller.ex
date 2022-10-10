defmodule AppWeb.GroupMemberController do
  use AppWeb, :controller
  alias App.{Group, Person}
  import Ecto.Changeset

  # plug :permission_tag when action in [:edit, :update, :delete]

  def index(conn, %{"group_id" => group_id}) do
    group = Group.get_group!(group_id)
    changeset = Person.changeset(%Person{})
    # person_id = conn.assigns[:person][:id] || 0
    # tags = Tag.list_person_tags(person_id)

    render(conn, "index.html", changeset: changeset, group: group)
  end

  def create(conn, %{"group_id" => group_id, "person" => %{"name" => name}}) do
    group = Group.get_group!(group_id)

    case Person.get_person_by_name(name) do
      nil ->
        changeset =
          %Person{name: name}
          |> change()
          |> add_error(:name, "This name doesn't seem to exist")
          |> Map.put(:action, :insert)

        render(conn, "index.html", changeset: changeset, group: group)

      person ->
        redirect(conn,
          to: Routes.group_group_member_path(conn, :index, group_id)
        )
    end
  end
end
