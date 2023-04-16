defmodule App.ListTest do
  use App.DataCase
  alias App.{List}

  describe "list" do
    @valid_attrs %{name: "some text", person_id: 1, status: 2}
    @update_attrs %{name: "some updated text", person_id: 1}
    @invalid_attrs %{name: nil}

    # test "get_item!/2 returns the item with given id" do
    #   {:ok, %{model: item, version: _version}} = Item.create_item(@valid_attrs)
    #   assert Item.get_item!(item.id).text == item.text
    # end

    # test "get_item/2 returns the item with given id with tags" do
    #   {:ok, %{model: item, version: _version}} = Item.create_item(@valid_attrs)

    #   tags = Map.get(Item.get_item(item.id, true), :tags)

    #   assert Item.get_item(item.id, true).text == item.text
    #   assert not is_nil(tags)
    # end

    test "create_list/1 with valid data creates a list" do
      assert {:ok, %{model: list, version: _version}} =
               List.create_list(@valid_attrs)

      assert list.name == "some text"

      # inserted_item = List.first(Item.list_items())
      # assert inserted_item.text == @valid_attrs.text
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

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_list(@invalid_attrs)
    end

    # test "list_items/0 returns a list of items stored in the DB" do
    #   {:ok, %{model: _item1, version: _version}} =
    #     Item.create_item(@valid_attrs)

    #   {:ok, %{model: _item2, version: _version}} =
    #     Item.create_item(@valid_attrs)

    #   assert Enum.count(Item.list_items()) == 2
    # end

    test "update_item/2 with valid data updates the item" do
      {:ok, %{model: list, version: _version}} = List.create_list(@valid_attrs)

      assert {:ok, %{model: list, version: _version}} =
               List.update_list(list, @update_attrs)

      assert list.name == "some updated text"
    end
  end
end
