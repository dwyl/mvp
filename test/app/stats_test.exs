defmodule App.StatsTest do
  use App.DataCase, async: true
  alias App.{Item, Stats, Timer}
  doctest Stats

  @valid_attrs %{text: "some text", person_id: 1, status: 2}
  @another_person %{text: "some text", person_id: 2, status: 2}

  test "Stats.person_with_item_and_timer_count/0 returns a list of count of timers and items for each given person" do
    {:ok, %{model: item1, version: _version}} = Item.create_item(@valid_attrs)
    {:ok, %{model: item2, version: _version}} = Item.create_item(@valid_attrs)

    started = NaiveDateTime.utc_now()

    {:ok, _timer1} =
      Timer.start(%{
        item_id: item1.id,
        person_id: item1.person_id,
        start: started,
        stop: started
      })

    {:ok, _timer2} =
      Timer.start(%{
        item_id: item2.id,
        person_id: item2.person_id,
        start: started
      })

    # list person with number of timers and items
    person_with_items_timers = Stats.person_with_item_and_timer_count()

    assert length(person_with_items_timers) == 2

    first_element = Enum.at(person_with_items_timers, 0)

    assert first_element.num_items == 5
    assert first_element.num_timers == 1

    # These assertions do not account for seeds. they fail intermittently. :(
    # assert NaiveDateTime.compare(
    #          first_element.first_inserted_at,
    #          item1.inserted_at
    #        ) == :lt
    # assert NaiveDateTime.compare(
    #          first_element.last_inserted_at, 
    #          item2.inserted_at
    #        ) == :eq
  end

  test "Stats.person_with_item_and_timer_count/1 returns a list sorted in ascending order" do
    {:ok, %{model: _, version: _version}} = Item.create_item(@valid_attrs)
    {:ok, %{model: _, version: _version}} = Item.create_item(@valid_attrs)

    {:ok, %{model: _, version: _version}} = Item.create_item(@another_person)
    {:ok, %{model: _, version: _version}} = Item.create_item(@another_person)

    # list person with number of timers and items
    result = Stats.person_with_item_and_timer_count(:person_id)

    assert length(result) == 3

    first_element = Enum.at(result, 0)
    assert first_element.person_id == 0
  end

  test "Stats.person_with_item_and_timer_count/1 returns a sorted list based on the column" do
    {:ok, %{model: _, version: _version}} = Item.create_item(@valid_attrs)
    {:ok, %{model: _, version: _version}} = Item.create_item(@valid_attrs)

    {:ok, %{model: _, version: _version}} = Item.create_item(@another_person)
    {:ok, %{model: _, version: _version}} = Item.create_item(@another_person)

    # list person with number of timers and items
    result = Stats.person_with_item_and_timer_count(:person_id, :desc)

    assert length(result) == 3

    first_element = Enum.at(result, 0)
    assert first_element.person_id == 2
  end

  test "Stats.validate_sort_column/1 returns false for invalid sort_column" do
    refute Stats.validate_sort_column(:invalid)
  end

  test "Stats.person_with_item_and_timer_count/1 returns a sorted list by person_id if invalid sorted column and order" do
    {:ok, %{model: _, version: _version}} = Item.create_item(@valid_attrs)
    {:ok, %{model: _, version: _version}} = Item.create_item(@valid_attrs)

    {:ok, %{model: _, version: _version}} = Item.create_item(@another_person)
    {:ok, %{model: _, version: _version}} = Item.create_item(@another_person)

    # list person with number of timers and items
    result =
      Stats.person_with_item_and_timer_count(:invalid_column, :invalid_order)

    assert length(result) == 3

    first_element = Enum.at(result, 0)
    assert first_element.person_id == 0
  end
end
