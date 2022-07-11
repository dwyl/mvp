defmodule App.ItemTest do
  use App.DataCase
  alias App.{Item, Person, Status}

  describe "items" do
    @valid_attrs %{text: "some text"}
    @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    def item_fixture(attrs \\ %{}) do
      person = Person.get_person!(1)
      status = Status.get_by_text!(:uncategorized)

      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Item.create_item(person, status)

      item
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture(@valid_attrs)
      assert Item.get_item!(item.id).text == item.text
    end

    test "create_item/1 with valid data creates a item" do
      person = Person.get_person!(1)
      status = Status.get_by_text!(:uncategorized)

      assert {:ok, %Item{} = item} =
               Item.create_item(@valid_attrs, person, status)

      assert item.text == "some text"

      inserted_item = List.first(Item.list_items())
      assert inserted_item.text == @valid_attrs.text
    end

    test "create_item/1 with invalid data returns error changeset" do
      person = Person.get_person!(1)
      status = Status.get_by_text!(:uncategorized)

      assert {:error, %Ecto.Changeset{}} =
               Item.create_item(@invalid_attrs, person, status)
    end

    test "list_items/0 returns a list of todo items stored in the DB" do
      _item1 = item_fixture()
      _item2 = item_fixture()
      items = Item.list_items()
      assert Enum.count(items) == 2
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()

      assert {:ok, %Item{} = item} = Item.update_item(item, @update_attrs)
      assert item.text == "some updated text"
    end
  end
end
