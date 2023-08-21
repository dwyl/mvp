defmodule App.ListItemsTest do
  use App.DataCase, async: true
  alias App.{Item, List, ListItems}

  describe "add items to list" do
    @person_id 1
    @valid_item_attrs %{text: "some text", person_id: @person_id, status: 2}
    @valid_list_attrs %{name: "some list", person_id: @person_id, sort: 1, status: 2}



    test "get_list_items/1 retrieves the list of items (seq) from list_items for the list_id" do
      # No list No list_items:
      assert App.ListItems.get_list_items(0) == []

      # Create an item
      assert {:ok, %{model: item}} = Item.create_item(@valid_item_attrs)
      # Create list
      assert {:ok, %{model: list}} = List.create_list(@valid_list_attrs)

      # add the item to the lists_items:
      ListItems.add_list_item(item, list, @person_id)

      # Confirm the item.id is in the list_items.seq:
      assert Enum.member?(ListItems.get_list_items(list.id), "#{item.id}")


    end

    # test "add_list_item/3 adds an item to the list for the person_id" do

    # end

    # test "add_list_item/3 adds an item to a list" do
    #   # Create an item
    #   assert {:ok, %{model: item, version: _version}} =
    #            Item.create_item(@valid_item_attrs)

    #   assert item.text == @valid_item_attrs.text

    #   # Create list
    #   assert {:ok, %{model: list, version: _version}} =
    #            List.create_list(@valid_list_attrs)

    #   assert list.text == @valid_list_attrs.text

    #   # Add the item to the list:
    #   assert {:ok, list_item} = ListItem.add_list_item(item, list, 1, 42.0)
    #   # dbg(list_item)
    #   assert list_item.item_id == item.id
    #   assert list_item.list_id == list.id
    #   assert list_item.person_id == item.person_id

    #   # Create SECOND list to confirm that an item
    #   # can be added to multiple lists
    #   list2_data = %{text: "Second List", person_id: 1, status: 2}

    #   assert {:ok, %{model: list2, version: _version}} =
    #            List.create_list(list2_data)

    #   assert list2.text == list2_data.text

    #   # Add the item to the list:
    #   assert {:ok, list_item2} = ListItem.add_list_item(item, list2, 1, 42.0)
    #   assert list_item2.list_id !== list_item.list_id
    # end

    # test "remove_list_item/2 removes an item from a list" do
    #   # Create an item
    #   assert {:ok, %{model: item, version: _version}} =
    #            Item.create_item(@valid_item_attrs)

    #   # Create list
    #   assert {:ok, %{model: list, version: _version}} =
    #            List.create_list(@valid_list_attrs)

    #   assert list.text == @valid_list_attrs.text

    #   # Add the item to the list:
    #   assert {:ok, list_item} = ListItem.add_list_item(item, list, 1, 42.0)
    #   # dbg(list_item)
    #   assert list_item.item_id == item.id
    #   assert list_item.list_id == list.id

    #   # "REMOVE" the item from the list:
    #   # See: github.com/dwyl/mvp/issues/357
    #   assert {:ok, list_item_removed} = ListItem.remove_list_item(item, list, 1)
    #   assert list_item_removed.position == 999_999.999
    # end

    # @valid_attrs %{text: "Buy Bananas", person_id: 0, status: 2}
    # test "get_list_item_position/2 retrieves the position of an item in a list" do
    #   {:ok, %{model: item, version: _version}} =
    #     Item.create_item(@valid_attrs)

    #   {:ok, li1} = App.ListItem.add_item_to_all_list(item)
    #   assert li1.position == 1.0

    #   # Note: this conversion from Int to Binary is to simulate the
    #   # binary that the LiveView sends to this function ...
    #   item_id = Integer.to_string(item.id)
    #   pos = App.ListItem.get_list_item_position(item_id, li1.list_id)

    #   assert li1.position == pos
    # end

    # test "App.ListItem.next_position_on_list/1 retrieve next position" do
    #   person_id = 7
    #   App.List.create_list(%{text: "all", person_id: person_id})
    #   all_list = App.List.get_list_by_name!(person_id, "all")
    #   pos_before = App.ListItem.next_position_on_list(all_list.id)
    #   assert pos_before == 1.0

    #   item_ids = App.ListItem.get_items_on_all_list(person_id)
    #   assert length(item_ids) == 0

    #   # Add an new item for the person:
    #   {:ok, %{model: item}} =
    #     %{text: "hai", person_id: person_id, status: 2}
    #     |> Item.create_item()

    #   App.ListItem.add_item_to_all_list(item)

    #   updated_item_ids = App.ListItem.get_items_on_all_list(person_id)

    #   assert length(updated_item_ids) ==
    #            length(App.Item.all_items_for_person(person_id))

    #   pos_after = App.ListItem.next_position_on_list(all_list.id)
    #   assert pos_before + length(updated_item_ids) == pos_after
    # end

    # test "move_item/3 repositions an item in the list" do
    #   {:ok, %{model: item1, version: _version}} = Item.create_item(@valid_attrs)
    #   {:ok, %{model: item2, version: _version}} = Item.create_item(@valid_attrs)
    #   # Items must be on a list ...
    #   {:ok, li1} = App.ListItem.add_item_to_all_list(item1)
    #   {:ok, li2} = App.ListItem.add_item_to_all_list(item2)

    #   assert li1.position < li2.position

    #   # Get the "all" list for this person:
    #   list = App.List.get_list_by_name!(@valid_attrs.person_id, "all")
    #   item_list_str = "#{item2.id} #{item1.id}"
    #   dbg(item_list_str)
    #   # Move item2 to be above item1:
    #   {:ok, li3} = App.ListItem.move_item(item2.id, item_list_str, list.id)
    #   assert li3.position == 0.999999
    # end
  end
end
