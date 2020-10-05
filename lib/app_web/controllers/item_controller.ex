defmodule AppWeb.ItemController do
  use AppWeb, :controller
  alias App.Item

  def index(conn, _params) do
    items = Item.list_items()
    render(conn, "index.html", items: items)
  end

  def api_index(conn, _params) do
    items = Item.list_items()
    render(conn, "index.json", items: items)
  end

  def new(conn, _params) do
    changeset = Item.change_item(%Item{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    person = conn.assigns.person

    params =
      Map.merge(item_params, %{person_id: person.id, person: person})
      |> Useful.atomize_map_keys()

    case Item.create_item(params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: Routes.item_path(conn, :show, item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Item.get_item!(id)
    render(conn, "show.html", item: item)
  end

  def edit(conn, %{"id" => id}) do
    item = Item.get_item!(id)
    changeset = Item.change_item(item)
    render(conn, "edit.html", item: item, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Item.get_item!(id)

    case Item.update_item(item, item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "Item updated successfully.")
        |> redirect(to: Routes.item_path(conn, :show, item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item: item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Item.get_item!(id)
    {:ok, _item} = Item.delete_item(item)

    conn
    |> put_flash(:info, "Item deleted successfully.")
    |> redirect(to: Routes.item_path(conn, :index))
  end
end
