defmodule App.ItemTest do
  use App.DataCase
  alias App.Item

  describe "items" do
    @valid_attrs %{text: "some text", person_id: 1}
    @update_attrs %{text: "some updated text", status: 1}
    @invalid_attrs %{text: nil}


    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Item.create_item()

      item
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture(@valid_attrs)
      assert Item.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Item.create_item(@valid_attrs)
      assert item.text == "some text"

      inserted_item = List.first(Item.list_items())
      assert inserted_item.text == @valid_attrs.text
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Item.create_item(@invalid_attrs)
    end

    test "list_items/0 returns a list of todo items stored in the DB" do
      item1 = item_fixture()
      item2 = item_fixture()
      items = Item.list_items()
      assert Enum.member?(items, item1)
      assert Enum.member?(items, item2)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Item.update_item(item, @update_attrs)
      assert item.text == "some updated text"
    end

    test "delete_item/1 soft-deltes an item" do
      item = item_fixture()
      assert {:ok, %Item{} = deleted_item} = Item.delete_item(item.id)
      assert deleted_item.status == 6
    end
  end
end
