defmodule App.ItemTest do
  use App.DataCase
  alias App.{Item, Timer}

  describe "items" do
    @valid_attrs %{text: "Buy Bananas", person_id: 1, status: 2}
    @update_attrs %{text: "some updated text", person_id: 1}
    @invalid_attrs %{text: nil}

    test "get_item!/2 returns the item with given id" do
      {:ok, %{model: item}} = Item.create_item(@valid_attrs)
      assert Item.get_item!(item.id).text == item.text
    end

    test "get_item/2 returns the item with given id with tags" do
      {:ok, %{model: item}} = Item.create_item(@valid_attrs)

      tags = Map.get(Item.get_item(item.id, true), :tags)

      assert Item.get_item(item.id, true).text == item.text
      assert not is_nil(tags)
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %{model: item}} =
               Item.create_item(@valid_attrs)

      # dbg(item)
      assert item.text == @valid_attrs.text

      inserted_item = List.first(Item.get_items())
      assert inserted_item.text == "Use the MVP!"
    end

    test "create_item/1 with long text" do
      attrs = %{
        text: "This is a long text, This is a long text,
                This is a long text,This is a long text,This is a long text,
                This is a long text,This is a long text,This is a long text,
                This is a long text,This is a long text,This is a long text,
                This is a long text,This is a long text,This is a long text,
                This is a long text,This is a long text,This is a long text,
            ",
        person_id: 1,
        status: 2
      }

      assert {:ok, %{model: item}} = Item.create_item(attrs)

      assert item.text == attrs.text
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Item.create_item(@invalid_attrs)
    end

    # test "list_items/0 returns a list of items stored in the DB" do
    #   {:ok, %{model: _item1}} =
    #     Item.create_item(@valid_attrs)

    #   {:ok, %{model: _item2}} =
    #     Item.create_item(@valid_attrs)

    #   assert Enum.count(Item.list_items()) == 2
    # end

    test "update_item/2 with valid data updates the item" do
      {:ok, %{model: item}} = Item.create_item(@valid_attrs)

      assert {:ok, %{model: item}} =
               Item.update_item(item, @update_attrs)

      assert item.text == "some updated text"
    end
  end

  describe "items with tags" do
    @valid_attrs %{
      text: "new item",
      person_id: 1,
      status: 2,
      tags: []
    }

    test "get_item!/1 returns the item with given id" do
      {:ok, %{model: item}} =
        Item.create_item_with_tags(@valid_attrs)

      assert length(item.tags) == 0
    end
  end

  describe "accumulate timers for a list of items #103" do
    test "accummulate_item_timers/1 to display cumulative timer" do
      # https://hexdocs.pm/elixir/1.13/NaiveDateTime.html#new/2
      # "Add" -7 seconds: https://hexdocs.pm/elixir/1.13/Time.html#add/3
      {:ok, seven_seconds_ago} =
        NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

      items_with_timers = [
        %{
          stop: nil,
          id: 3,
          start: nil,
          text: "This item has no timers",
          timer_id: nil,
          cid: "3"
        },
        %{
          stop: ~N[2022-07-17 11:18:10.000000],
          id: 2,
          start: ~N[2022-07-17 11:18:00.000000],
          text:
            "Item #2 has one active (no end) and one complete timer should total 17sec",
          timer_id: 3,
          cid: "2"
        },
        %{
          stop: nil,
          id: 2,
          start: seven_seconds_ago,
          text:
            "Item #2 has one active (no end) and one complete timer should total 17sec",
          timer_id: 4,
          cid: "2"
        },
        %{
          stop: ~N[2022-07-17 11:18:31.000000],
          id: 1,
          start: ~N[2022-07-17 11:18:26.000000],
          text:
            "Item with 3 complete timers that should add up to 42 seconds elapsed",
          timer_id: 2,
          cid: "1"
        },
        %{
          stop: ~N[2022-07-17 11:18:24.000000],
          id: 1,
          start: ~N[2022-07-17 11:18:18.000000],
          text:
            "Item with 3 complete timers that should add up to 42 seconds elapsed",
          timer_id: 1,
          cid: "1"
        },
        %{
          stop: ~N[2022-07-17 11:19:42.000000],
          id: 1,
          start: ~N[2022-07-17 11:19:11.000000],
          text:
            "Item with 3 complete timers that should add up to 42 seconds elapsed",
          timer_id: 5,
          cid: "1"
        }
      ]

      # The *interesting* timer is the *active* one (started seven_seconds_ago) ...
      # The "hard" part to test in accumulating timers are the *active* ones ...
      seq = ["3", "2", "1"]
      acc = Item.accumulate_item_timers(items_with_timers, seq)
      item_map = Map.new(acc, fn item -> {item.id, item} end)
      item1 = Map.get(item_map, 1)
      item2 = Map.get(item_map, 2)
      item3 = Map.get(item_map, 3)

      # It's easy to calculate time elapsed for timers that have an stop:
      assert NaiveDateTime.diff(item1.stop, item1.start) == 42
      # This is the fun one that we need to be 17 seconds:
      assert NaiveDateTime.diff(NaiveDateTime.utc_now(), item2.start) == 17

      # The diff will always be 17 seconds because we control the start in the test data above.
      # But we still get the function to calculate it so we know it works.

      # The 3rd item doesn't have any timers, its the control:
      assert item3.start == nil
    end

    test "Item.items_with_timers/1 returns a list of items with timers" do
      {:ok, %{model: item1}} = Item.create_item(@valid_attrs)
      {:ok, %{model: item2}} = Item.create_item(@valid_attrs)

      assert Item.get_item!(item1.id).text == item1.text

      started = NaiveDateTime.utc_now()

      {:ok, timer1} =
        Timer.start(%{
          item_id: item1.id,
          person_id: 1,
          start: started,
          stop: started
        })

      {:ok, _timer2} =
        Timer.start(%{item_id: item2.id, person_id: 1, start: started})

      assert NaiveDateTime.diff(timer1.start, started) == 0

      # Item must be on a list ...
      App.List.add_all_items_to_all_list_for_person_id(item1.person_id)
      # list items with timers:
      item_timers = Item.items_with_timers(1)
      assert length(item_timers) > 0
    end
  end
end
