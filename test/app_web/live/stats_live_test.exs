defmodule AppWeb.StatsLiveTest do
  use AppWeb.ConnCase, async: true
  alias App.{Item, Timer}
  import Phoenix.LiveViewTest

  @person_id 55

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/stats")
    assert disconnected_html =~ "Stats"
    assert render(page_live) =~ "Stats"
  end

  test "display metrics on mount", %{conn: conn} do
    {:ok, page_live, _html} = live(conn, "/stats")

    # Creating two items
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, _item2} =
      Item.create_item(%{text: "Learn Elixir", status: 4, person_id: @person_id})

    assert item.status == 2

    # Creating one timer
    started = NaiveDateTime.utc_now()
    {:ok, _timer} = Timer.start(%{item_id: item.id, start: started})

    assert render(page_live) =~ "Stats"
    # num of items
    assert render(page_live) =~ "2"
    # num of timers
    assert render(page_live) =~ "1"
  end

  test "handle broadcast when item is created", %{conn: conn} do
    # Creating an item
    {:ok, _item} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # num of items
    assert render(page_live) =~ "1"

    # Creating another item.
    AppWeb.Endpoint.broadcast(
      "stats",
      "item",
      {:create, payload: %{person_id: @person_id}}
    )

    # num of items
    assert render(page_live) =~ "2"

    # Broadcasting update. Shouldn't effect anything in the page
    AppWeb.Endpoint.broadcast(
      "stats",
      "item",
      {:update, payload: %{person_id: @person_id}}
    )

    # num of items
    assert render(page_live) =~ "2"
  end

  test "handle broadcast when timer is created", %{conn: conn} do
    # Creating an item
    {:ok, _item} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # num of timers
    assert render(page_live) =~ "0"

    # Creating a timer.
    AppWeb.Endpoint.broadcast(
      "stats",
      "timer",
      {:create, payload: %{person_id: @person_id}}
    )

    # num of timers
    assert render(page_live) =~ "1"

    # Broadcasting update. Shouldn't effect anything in the page
    AppWeb.Endpoint.broadcast(
      "stats",
      "timer",
      {:update, payload: %{person_id: @person_id}}
    )

    # num of timers
    assert render(page_live) =~ "1"
  end

  test "add_row/2 adds 1 to row.num_timers" do
    row = %{person_id: 1, num_timers: 1}
    payload = %{person_id: 1}

    # expect row.num_timers to be incremented by 1:
    row_updated = AppWeb.StatsLive.add_row(row, payload)
    assert row_updated == %{person_id: 1, num_timers: 2}

    # no change expected:
    row2 = %{person_id: 2, num_timers: 42}
    assert row2 == AppWeb.StatsLive.add_row(row2, payload)
  end
end
