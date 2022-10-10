defmodule AppWeb.GroupListController do
  use AppWeb, :controller
  alias App.{Group, List}

  def index(conn, %{"group_id" => group_id}) do
    person_id = conn.assigns[:person][:id]
    group = Group.get_group!(group_id)

    lists =
      List.list_person_lists(person_id)
      |> Enum.concat(group.lists)
      |> Enum.uniq_by(& &1.id)
      |> Enum.map(&{&1.name, &1.id})

    selected_list_ids = Enum.map(group.lists, & &1.id)

    data = %{}
    types = %{selected_lists: {:array, :string}}
    params = %{selected_lists: selected_list_ids}

    changeset =
      {data, types}
      |> Ecto.Changeset.cast(params, Map.keys(types))

    render(conn, "index.html",
      group: group,
      lists: lists,
      changeset: changeset
    )
  end

  def create(conn, %{"group_id" => group_id} = params) do
    group = Group.get_group!(group_id)

    list_ids =
      case params["group_lists"]["selected_lists"] do
        "" -> []
        ids -> ids
      end

    {:ok, _group} = Group.update_group_with_lists(group, list_ids)

    conn
    |> put_flash(:info, "Group's lists updated successfully.")
    |> redirect(to: Routes.group_path(conn, :index))
  end
end
