defmodule App.TimerTest do
  use App.DataCase
  alias App.{Item, Person, Status, Timer}

  describe "timers" do
    @valid_item_attrs %{text: "some text", person_id: 1}
    # @update_attrs %{text: "some updated text", status: 1}
    # @invalid_attrs %{text: nil}

    def item_fixture(attrs \\ %{}) do
      person = Person.get_person!(1)
      status = Status.get_by_text!(:uncategorized)

      {:ok, item} =
        attrs
        |> Enum.into(@valid_item_attrs)
        |> Item.create_item(person, status)

      item
    end

    test "Timer.start/1 returns timer that has been started" do
      item = item_fixture(@valid_item_attrs)
      assert Item.get_item!(item.id).text == item.text

      started = NaiveDateTime.utc_now()

      {:ok, timer} =
        Timer.start(%{item_id: item.id, person_id: 1, start: started})

      assert NaiveDateTime.diff(timer.start, started) == 0
    end

    test "Timer.stop/1 stops the timer that had been started" do
      item = item_fixture(@valid_item_attrs)
      assert Item.get_item!(item.id).text == item.text

      started = NaiveDateTime.utc_now()

      {:ok, timer} =
        Timer.start(%{item_id: item.id, person_id: 1, start: started})

      assert NaiveDateTime.diff(timer.start, started) == 0

      # IO.puts "waiting 1 second ... " ; :timer.sleep(1000); IO.puts "done"
      Process.sleep(1000)

      ended = NaiveDateTime.utc_now()
      {:ok, timer} = Timer.stop(%{id: timer.id, end: ended})
      assert NaiveDateTime.diff(timer.end, timer.start) == 1
    end
  end
end
