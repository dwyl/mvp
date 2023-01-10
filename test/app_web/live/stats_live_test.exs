defmodule AppWeb.StatsLiveTest do
  use AppWeb.ConnCase
  alias App.{Item, Person, Timer, Tag}
  import Phoenix.LiveViewTest
  alias Phoenix.Socket.Broadcast

  @person_id 55

  # setup [:create_person]

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
    {:ok, item} =
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
    {:ok, item} =
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

  # defp create_person(_) do
  #   person =
  #     Person.create_person(%{"person_id" => @person_id, "name" => "guest"})

  #   %{person: person}
  # end
end
