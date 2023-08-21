defmodule AppWeb.StatsLiveTest do
  alias App.DateTimeHelper
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
    # Creating two items
    {:ok, %{model: item, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, %{model: _item2, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 4, person_id: @person_id})

    assert item.status == 2

    # Creating one timer
    started = NaiveDateTime.utc_now()
    {:ok, timer} = Timer.start(%{item_id: item.id, start: started})
    {:ok, _} = Timer.stop(%{id: timer.id})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"

    # two items and one timer expected
    assert page_live |> element("td[data-test-id=person_id]") |> render() =~
             "55"

    assert page_live |> element("td[data-test-id=num_items]") |> render() =~ "2"

    assert page_live |> element("td[data-test-id=num_timers]") |> render() =~
             "1"

    assert page_live
           |> element("td[data-test-id=first_inserted_at]")
           |> render() =~
             DateTimeHelper.format_date(started)

    assert page_live
           |> element("td[data-test-id=last_inserted_at]")
           |> render() =~
             DateTimeHelper.format_date(started)

    assert page_live
           |> element("td[data-test-id=total_timers_in_seconds]")
           |> render() =~
             ""
  end

  test "handle broadcast when item is created", %{conn: conn} do
    # Creating an item
    {:ok, %{model: _item, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # num of items
    assert page_live |> element("td[data-test-id=num_items]") |> render() =~ "1"

    # Creating another item.
    AppWeb.Endpoint.broadcast(
      "stats",
      "item",
      {:create, payload: %{person_id: @person_id}}
    )

    # num of items
    assert page_live |> element("td[data-test-id=num_items]") |> render() =~ "2"

    # Broadcasting update. Shouldn't effect anything in the page
    AppWeb.Endpoint.broadcast(
      "stats",
      "item",
      {:update, payload: %{person_id: @person_id}}
    )

    # num of items
    assert page_live |> element("td[data-test-id=num_items]") |> render() =~ "2"
  end

  test "handle broadcast when timer is created", %{conn: conn} do
    # Creating an item
    {:ok, %{model: _item, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # num of timers
    assert page_live |> element("td[data-test-id=num_timers]") |> render() =~
             "0"

    # Creating a timer.
    AppWeb.Endpoint.broadcast(
      "stats",
      "timer",
      {:create, payload: %{person_id: @person_id}}
    )

    # num of timers
    assert page_live |> element("td[data-test-id=num_timers]") |> render() =~
             "1"

    # Broadcasting update. Shouldn't effect anything in the page
    AppWeb.Endpoint.broadcast(
      "stats",
      "timer",
      {:update, payload: %{person_id: @person_id}}
    )

    # num of timers
    assert page_live |> element("td[data-test-id=num_timers]") |> render() =~
             "1"
  end

  test "add_row/3 adds 1 to row.num_timers" do
    row = %{person_id: 1, num_items: 1, num_timers: 1}
    payload = %{person_id: 1}

    # expect row.num_timers to be incremented by 1:
    row_updated = AppWeb.StatsLive.add_row(row, payload, :num_timers)
    assert row_updated == %{person_id: 1, num_items: 1, num_timers: 2}

    # no change expected:
    row2 = %{person_id: 2, num_items: 1, num_timers: 42}
    assert row2 == AppWeb.StatsLive.add_row(row2, payload, :num_timers)
  end

  test "sorting column when clicked", %{conn: conn} do
    {:ok, %{model: _, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: 1})

    {:ok, %{model: _, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 4, person_id: 2})

    {:ok, page_live, _html} = live(conn, "/stats")

    # sort first time
    result =
      page_live |> element("th[phx-value-key=person_id]") |> render_click()

    [first_element | _] = Floki.find(result, "td[data-test-id=person_id]")

    assert first_element |> Floki.text() =~ "2"

    # sort second time
    result =
      page_live |> element("th[phx-value-key=person_id]") |> render_click()

    [first_element | _] = Floki.find(result, "td[data-test-id=person_id]")

    assert first_element |> Floki.text() =~ "1"
  end
end
