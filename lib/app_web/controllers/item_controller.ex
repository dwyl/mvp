defmodule AppWeb.ItemController do
  use AppWeb, :controller
  alias App.{Item, List}
  # plug :permission_tag when action in [:edit, :update, :delete]

  def edit(conn, %{"id" => id}) do
    person_id = conn.assigns[:person][:id] || 0

    item = Item.get_item!(id)
    lists = List.list_person_lists(person_id)

    changeset = Item.changeset(item)
    render(conn, "edit.html", item: item, lists: lists, changeset: changeset)
  end
end
