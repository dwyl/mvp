defmodule App.ListTest do
  use App.DataCase
  alias App.{List}

  describe "list" do
    @valid_attrs %{text: "some text", person_id: 1, status: 2}
    @update_attrs %{text: "some updated text", person_id: 1}
    @invalid_attrs %{text: nil}

    test "get_list!/2 returns the list with given id" do
      {:ok, %{model: list, version: _version}} = List.create_list(@valid_attrs)
      assert List.get_list!(list.id).text == list.text
    end

    # test "get_item/2 returns the item with given id with tags" do
    #   {:ok, %{model: item, version: _version}} = Item.create_item(@valid_attrs)

    #   tags = Map.get(Item.get_item(item.id, true), :tags)

    #   assert Item.get_item(item.id, true).text == item.text
    #   assert not is_nil(tags)
    # end

    test "create_list/1 with valid data creates a list" do
      assert {:ok, %{model: list, version: _version}} =
               List.create_list(@valid_attrs)

      assert list.text == "some text"
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_list(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      {:ok, %{model: list, version: _version}} = List.create_list(@valid_attrs)

      assert {:ok, %{model: list, version: _version}} =
               List.update_list(list, @update_attrs)

      assert list.text == "some updated text"
    end
  end
end
