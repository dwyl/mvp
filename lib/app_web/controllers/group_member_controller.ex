defmodule AppWeb.GroupMemberController do
  use AppWeb, :controller
  alias App.{Group, Person}
  # plug :permission_tag when action in [:edit, :update, :delete]

  def index(conn, %{"group_id" => group_id}) do
    group = Group.get_group!(group_id)
    changeset = Person.changeset(%Person{})
    # person_id = conn.assigns[:person][:id] || 0
    # tags = Tag.list_person_tags(person_id)

    render(conn, "index.html", changeset: changeset, group: group)
  end

  def create(conn, %{"group_id" => group_id} = params) do
    IO.inspect(params)
    redirect(conn, to: Routes.group_group_member_path(conn, :index, group_id))
  end
end
