defmodule AppWeb.ItemControllerTest do
  use AppWeb.ConnCase

  alias App.{List, Person, Item}

  setup [:create_person]

  @create_attrs %{name: "list1", person_id: 1}
  @create_attrs_item %{text: "item1", person_id: 1}

  def fixture(:list) do
    {:ok, list} = List.create_list(@create_attrs)
    list
  end

  def fixture(:item) do
    {:ok, item} = Item.create_item(@create_attrs_item)
    item
  end

  describe "edit item's list" do
    setup [:create_item, :create_list]

    test "renders form for editing item's lists", %{
      conn: conn,
      item: item
    } do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> get(Routes.item_path(conn, :edit, item))

      assert html_response(conn, 200) =~ "Edit Item"
    end
  end

  describe "update item's list" do
    setup [:create_item, :create_list]

    test "Add a list to an item", %{
      conn: conn,
      list: list,
      item: item
    } do
      update_params = %{item_lists: [list.id]}

      conn =
        conn
        |> assign(:person, %{id: 1})
        |> put(Routes.item_path(conn, :update, item), item: update_params)

      assert length(Item.get_item!(item.id).lists) == 1

      assert redirected_to(conn) == "/"
    end

    test "Remove list from item", %{
      conn: conn,
      item: item
    } do
      update_params = %{item_lists: ""}

      conn =
        conn
        |> assign(:person, %{id: 1})
        |> put(Routes.item_path(conn, :update, item), item: update_params)

      assert length(Item.get_item!(item.id).lists) == 0

      assert redirected_to(conn) == "/"
    end
  end

  defp create_list(_) do
    list = fixture(:list)
    %{list: list}
  end

  defp create_item(_) do
    item = fixture(:item)
    %{item: item}
  end

  defp create_person(_) do
    person = Person.create_person(%{"person_id" => 0, "name" => "guest"})
    _person1 = Person.create_person(%{"person_id" => 1, "name" => "person1"})
    %{person: person}
  end
end
