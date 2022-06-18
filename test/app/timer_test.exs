defmodule App.TimerTest do
  use App.DataCase
  alias App.Timer

  describe "timers" do
    @valid_attrs %{end: ~N[2010-04-17 14:00:00], start: ~N[2010-04-17 14:00:00]}
    @update_attrs %{
      end: ~N[2011-05-18 15:01:01],
      start: ~N[2011-05-18 15:01:01]
    }
    @invalid_attrs %{end: nil, start: nil}

    def timer_fixture(attrs \\ %{}) do
      {:ok, timer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timer.create_timer()

      timer
    end

    test "list_timers/0 returns all timers" do
      timer = timer_fixture()
      assert Timer.list_timers() == [timer]
    end

    test "get_timer!/1 returns the timer with given id" do
      timer = timer_fixture()
      assert Timer.get_timer!(timer.id) == timer
    end

    test "create_timer/1 with valid data creates a timer" do
      assert {:ok, %Timer{} = timer} = Timer.create_timer(@valid_attrs)
      assert timer.end == ~N[2010-04-17 14:00:00]
      assert timer.start == ~N[2010-04-17 14:00:00]
    end

    test "create_timer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timer.create_timer(@invalid_attrs)
    end

    test "update_timer/2 with valid data updates the timer" do
      timer = timer_fixture()
      assert {:ok, %Timer{} = timer} = Timer.update_timer(timer, @update_attrs)
      assert timer.end == ~N[2011-05-18 15:01:01]
      assert timer.start == ~N[2011-05-18 15:01:01]
    end

    test "update_timer/2 with invalid data returns error changeset" do
      timer = timer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Timer.update_timer(timer, @invalid_attrs)

      assert timer == Timer.get_timer!(timer.id)
    end

    test "delete_timer/1 deletes the timer" do
      timer = timer_fixture()
      assert {:ok, %Timer{}} = Timer.delete_timer(timer)
      assert_raise Ecto.NoResultsError, fn -> Timer.get_timer!(timer.id) end
    end

    test "change_timer/1 returns a timer changeset" do
      timer = timer_fixture()
      assert %Ecto.Changeset{} = Timer.change_timer(timer)
    end
  end
end
