defmodule AppWeb.ItemController do
  use AppWeb, :controller
  alias App.{Item, List}
  # plug :permission_tag when action in [:edit, :update, :delete]

  def edit(conn, %{"id" => id}) do
    person_id = conn.assigns[:person][:id] || 0

    item = Item.get_item!(id)
    lists = List.list_person_lists(person_id) |> Enum.map(&{&1.name, &1.id})
    selected_list_id = Enum.map(item.lists, & &1.id)

    changeset = Item.changeset(item, %{item_lists: selected_list_id})

    render(conn, "edit.html",
      item: item,
      lists: lists,
      changeset: changeset
    )
  end

  def update(conn, %{"id" => id} = params) do
    person_id = conn.assigns[:person][:id] || 0
    item = Item.get_item!(id)

    list_ids =
      case params["item"]["item_lists"] do
        "" -> []
        ids -> ids
      end

    case Item.update_item_with_lists(item, list_ids) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item's list updated successfully.")
        |> redirect(to: "/")

      {:error, %Ecto.Changeset{} = changeset} ->
        lists = List.list_person_lists(person_id) |> Enum.map(&{&1.name, &1.id})

        render(conn, "edit.html", item: item, lists: lists, changeset: changeset)
    end
  end
end
