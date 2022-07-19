defmodule App.TimerTest do
  use App.DataCase
  alias App.{Item, Timer}

  describe "timers" do
    @valid_item_attrs %{text: "some text", person_id: 1}

    test "Timer.start/1 returns timer that has been started" do
      {:ok, item} = Item.create_item(@valid_item_attrs)
      assert Item.get_item!(item.id).text == item.text

      started = NaiveDateTime.utc_now()

      {:ok, timer} =
        Timer.start(%{item_id: item.id, person_id: 1, start: started})

      assert NaiveDateTime.diff(timer.start, started) == 0
    end

    test "Timer.stop/1 stops the timer that had been started" do
      {:ok, item} = Item.create_item(@valid_item_attrs)
      assert Item.get_item!(item.id).text == item.text

      {:ok, started} = 
        NaiveDateTime.new(Date.utc_today, Time.add(Time.utc_now, -1))

      {:ok, timer} =
        Timer.start(%{item_id: item.id, person_id: 1, start: started})

      assert NaiveDateTime.diff(timer.start, started) == 0

      # IO.puts "waiting 1 second ... " ; :timer.sleep(1000); IO.puts "done"
      # Process.sleep(1000)

      ended = NaiveDateTime.utc_now()
      {:ok, timer} = Timer.stop(%{id: timer.id, end: ended})
      assert NaiveDateTime.diff(timer.end, timer.start) == 1
    end

    test "stop_timer_for_item_id(item_id) should stop the active timer (happy path)" do
      {:ok, item} = Item.create_item(@valid_item_attrs)
      {:ok, seven_seconds_ago} = 
        NaiveDateTime.new(Date.utc_today, Time.add(Time.utc_now, -7))
      # Start the timer 7 seconds ago:
      {:ok, timer} =
        Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})
      
      # stop the timer based on it's item_id
      Timer.stop_timer_for_item_id(item.id)
      
      stopped_timer = Timer.get_timer!(timer.id)
      assert NaiveDateTime.diff(stopped_timer.start, seven_seconds_ago) == 0
      assert NaiveDateTime.diff(stopped_timer.end, stopped_timer.start) == 7
    end

    # test "stop_timer_for_item_id(item_id) should not explode if there is no timer (unhappy path)" do
    #   {:ok, item} = Item.create_item(@valid_item_attrs)

    # end

    # test "stop_timer_for_item_id(item_id) should not melt down if there is no item (sad path)" do
    #   fake_item_id = # random int
    #       Timer.stop_timer_for_item_id(42)

    # end
  end

  describe "accumulate timers #103" do
    test "accummulate_item_timers/1 to display cummulative timer" do
      # https://hexdocs.pm/elixir/1.13/NaiveDateTime.html#new/2
      # "Add" -7 seconds: https://hexdocs.pm/elixir/1.13/Time.html#add/3
      {:ok, seven_seconds_ago} = 
        NaiveDateTime.new(Date.utc_today, Time.add(Time.utc_now, -7))

      items_with_timers = [
        %{
          end: nil,
          id: 3,
          start: nil,
          text: "This item has no timers",
          timer_id: nil
        },
        %{
          end: ~N[2022-07-17 11:18:10.000000],
          id: 2,
          start: ~N[2022-07-17 11:18:00.000000],
          text: "Item #2 has one active (no end) and one complete timer should total 17sec",
          timer_id: 3
        },
        %{
          end: nil,
          id: 2,
          start: seven_seconds_ago,
          text: "Item #2 has one active (no end) and one complete timer should total 17sec",
          timer_id: 4
        },
        %{
          end: ~N[2022-07-17 11:18:31.000000],
          id: 1,
          start: ~N[2022-07-17 11:18:26.000000],
          text: "Item with 3 complete timers that should add up to 42 seconds elapsed",
          timer_id: 2
        },
        %{
          end: ~N[2022-07-17 11:18:24.000000],
          id: 1,
          start: ~N[2022-07-17 11:18:18.000000],
          text: "Item with 3 complete timers that should add up to 42 seconds elapsed",
          timer_id: 1
        },
        %{
          end: ~N[2022-07-17 11:19:42.000000],
          id: 1,
          start: ~N[2022-07-17 11:19:11.000000],
          text: "Item with 3 complete timers that should add up to 42 seconds elapsed",
          timer_id: 5
        }
      ]
      
      # The *interesting* timer is the *active* one (started seven_seconds_ago) ...
      # The "hard" part to test in accumulating timers are the *active* ones ...
      acc = Item.accumulate_item_timers(items_with_timers)
      item_map = Map.new(acc, fn item -> {item.id, item} end)
      item1 = Map.get(item_map, 1)
      item2 = Map.get(item_map, 2)
      item3 = Map.get(item_map, 3)
      
      # It's easy to calculate time elapsed for timers that have an end:
      assert NaiveDateTime.diff(item1.end, item1.start) == 42
      # This is the fun one that we need to be 17 seconds:
      assert NaiveDateTime.diff(NaiveDateTime.utc_now(), item2.start) == 17
      # The diff will always be 17 seconds because we control the start in the test data above.
      # But we still get the function to calculate it so we know it works.

      # The 3rd item doesn't have any timers, its the control:
      assert item3.start == nil
    end
  end
end
