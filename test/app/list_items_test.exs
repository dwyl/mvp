defmodule App.ListItemsTest do
  use App.DataCase
  alias App.{Item, List, ListItem}

  describe "add items to list" do
    @valid_item_attrs %{text: "some text", person_id: 1, status: 2}
    @valid_list_attrs %{name: "some text", person_id: 1, status: 2}

    test "add_list_item/2 adds an item to a list" do
      # Create an item
      assert {:ok, %{model: item, version: _version}} =
        Item.create_item(@valid_item_attrs)
      assert item.text == "some text"
      dbg(item)

      # Create list
      assert {:ok, %{model: list, version: _version}} =
               List.create_list(@valid_list_attrs)
      assert list.name == "some text"

      # Add the item to the list:
      assert {:ok, list_item} = ListItem.add_list_item(item, list, 42.0)
      dbg(list_item)
    end

    # test "create_item/1 with long text" do
    #   attrs = %{
    #     text: "This is a long text, This is a long text,
    #             This is a long text,This is a long text,This is a long text,
    #             This is a long text,This is a long text,This is a long text,
    #             This is a long text,This is a long text,This is a long text,
    #             This is a long text,This is a long text,This is a long text,
    #             This is a long text,This is a long text,This is a long text,
    #         ",
    #     person_id: 1,
    #     status: 2
    #   }

    #   assert {:ok, %{model: item, version: _version}} = Item.create_item(attrs)

    #   assert item.text == attrs.text
    # end

    # test "create_list/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = List.create_list(@invalid_attrs)
    # end

    # test "list_items/0 returns a list of items stored in the DB" do
    #   {:ok, %{model: _item1, version: _version}} =
    #     Item.create_item(@valid_attrs)

    #   {:ok, %{model: _item2, version: _version}} =
    #     Item.create_item(@valid_attrs)

    #   assert Enum.count(Item.list_items()) == 2
    # end

    # test "update_item/2 with valid data updates the item" do
    #   {:ok, %{model: list, version: _version}} = List.create_list(@valid_attrs)

    #   assert {:ok, %{model: list, version: _version}} =
    #            List.update_list(list, @update_attrs)

    #   assert list.name == "some updated text"
    # end
  end
end
