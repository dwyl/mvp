defmodule App.ListItemsTest do
  use App.DataCase, async: true
  alias App.{Item, List, ListItem}

  describe "add items to list" do
    @valid_item_attrs %{text: "some text", person_id: 1, status: 2}
    @valid_list_attrs %{text: "some list", person_id: 1, status: 2}

    test "add_list_item/3 adds an item to a list" do
      # Create an item
      assert {:ok, %{model: item, version: _version}} =
               Item.create_item(@valid_item_attrs)

      assert item.text == @valid_item_attrs.text

      # Create list
      assert {:ok, %{model: list, version: _version}} =
               List.create_list(@valid_list_attrs)

      assert list.text == @valid_list_attrs.text

      # Add the item to the list:
      assert {:ok, list_item} = ListItem.add_list_item(item, list, 1, 42.0)
      # dbg(list_item)
      assert list_item.item_id == item.id
      assert list_item.list_id == list.id
      assert list_item.person_id == item.person_id

      # Create SECOND list to confirm that an item
      # can be added to multiple lists
      list2_data = %{text: "Second List", person_id: 1, status: 2}

      assert {:ok, %{model: list2, version: _version}} =
               List.create_list(list2_data)

      assert list2.text == list2_data.text

      # Add the item to the list:
      assert {:ok, list_item2} = ListItem.add_list_item(item, list2, 1, 42.0)
      assert list_item2.list_id !== list_item.list_id
    end

    test "remove_list_item/2 removes an item from a list" do
      # Create an item
      assert {:ok, %{model: item, version: _version}} =
               Item.create_item(@valid_item_attrs)

      # Create list
      assert {:ok, %{model: list, version: _version}} =
               List.create_list(@valid_list_attrs)

      assert list.text == @valid_list_attrs.text

      # Add the item to the list:
      assert {:ok, list_item} = ListItem.add_list_item(item, list, 1, 42.0)
      # dbg(list_item)
      assert list_item.item_id == item.id
      assert list_item.list_id == list.id

      # "REMOVE" the item from the list:
      # See: github.com/dwyl/mvp/issues/357
      assert {:ok, list_item_removed} = ListItem.remove_list_item(item, list, 1)
      assert list_item_removed.position == 999_999.999
    end

    test "add_items_to_all_list/1 to seed the All list" do
      person_id = 0
      item_ids = App.ListItem.get_items_on_all_list(person_id)
      assert length(item_ids) == 0
      App.ListItem.add_items_to_all_list(person_id)
      updated_item_ids = App.ListItem.get_items_on_all_list(person_id)
      # dbg(updated_item_ids)
      assert length(updated_item_ids) ==
               length(App.Item.all_items_for_person(person_id))
    end
  end
end
