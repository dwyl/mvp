defmodule App.ItemTest do
  use App.DataCase
  alias App.{Item, Timer}

  describe "items" do
    @valid_attrs %{text: "some text", person_id: 1, status_code: 2}
    @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    test "get_item!/1 returns the item with given id" do
      {:ok, item} = Item.create_item(@valid_attrs)
      assert Item.get_item!(item.id).text == item.text
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Item.create_item(@valid_attrs)

      assert item.text == "some text"

      inserted_item = List.first(Item.list_items())
      assert inserted_item.text == @valid_attrs.text
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Item.create_item(@invalid_attrs)
    end

    test "list_items/0 returns a list of items stored in the DB" do
      {:ok, _item1} = Item.create_item(@valid_attrs)
      {:ok, _item2} = Item.create_item(@valid_attrs)
      items = Item.list_items()
      # IO.inspect(items)
      assert Enum.count(items) == 2
    end

    test "update_item/2 with valid data updates the item" do
      {:ok, item} = Item.create_item(@valid_attrs)

      assert {:ok, %Item{} = item} = Item.update_item(item, @update_attrs)
      assert item.text == "some updated text"
    end

    test "Item.items_with_timers/1 returns a list of items with timers" do
      {:ok, item1} = Item.create_item(@valid_attrs)
      {:ok, item2} = Item.create_item(@valid_attrs)
      assert Item.get_item!(item1.id).text == item1.text

      started = NaiveDateTime.utc_now()

      {:ok, timer1} =
        Timer.start(%{item_id: item1.id, person_id: 1, start: started})
      {:ok, _timer2} =
        Timer.start(%{item_id: item2.id, person_id: 1, start: started})

      assert NaiveDateTime.diff(timer1.start, started) == 0

      # list items with timers:
      item_timers = Item.items_with_timers(1)
      # IO.inspect(item_timers)
      assert length(item_timers) > 0
    end
  end
end