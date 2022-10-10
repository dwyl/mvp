defmodule AppWeb.GroupMemberController do
  use AppWeb, :controller
  alias App.{Group, Person, Repo}
  import Ecto.Changeset

  def index(conn, %{"group_id" => group_id}) do
    group = Group.get_group!(group_id)
    changeset = Person.changeset(%Person{})

    render(conn, "index.html", changeset: changeset, group: group)
  end

  def create(conn, %{"group_id" => group_id, "person" => %{"name" => name}}) do
    group = Group.get_group!(group_id)

    case Person.get_person_by_name(name) do
      nil ->
        changeset =
          %Person{name: name}
          |> change()
          |> add_error(:name, "Person's name not found")
          |> Map.put(:action, :insert)

        render(conn, "index.html", changeset: changeset, group: group)

      person ->
        group
        |> change()
        |> put_assoc(:people, [person | group.people])
        |> Repo.update()

        redirect(conn,
          to: Routes.group_group_member_path(conn, :index, group_id)
        )
    end
  end
end
