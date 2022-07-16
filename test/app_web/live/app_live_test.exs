defmodule AppWeb.AppLiveTest do
  use AppWeb.ConnCase
  alias App.{Item, Timer}
  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "mind"
    assert render(page_live) =~ "mind"
  end

  test "connect and create an item", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_submit(view, :create, 
      %{text: "Learn Elixir", person_id: 1}) =~ "Learn Elixir"
  end

  test "toggle an item", %{conn: conn} do
    {:ok, item} = 
      Item.create_item(%{text: "Learn Elixir", status_code: 2, person_id: 1})
    {:ok, _item2} = 
      Item.create_item(%{text: "Learn Elixir", status_code: 4, person_id: 1})

    assert item.status_code == 2

    started = NaiveDateTime.utc_now()
    {:ok, _timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: started})

    # See: https://github.com/dwyl/useful/issues/17#issuecomment-1186070198
    # assert Useful.typeof(:timer_id) == "atom"
    assert Item.items_with_timers(1) > 0

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, :toggle, 
      %{"id" => item.id, "value" => "on"}) =~ "line-through"

    updated_item = Item.get_item!(item.id)
    assert updated_item.status_code == 4
  end

  test "(soft) delete an item", %{conn: conn} do
    {:ok, item} = Item.create_item(%{text: "Learn Elixir", person_id: 1, status_code: 2})

    assert item.status_code == 2

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :delete, %{"id" => item.id}) =~ "mind"

    updated_item = Item.get_item!(item.id)
    assert updated_item.status_code == 6
  end

  test "start a timer", %{conn: conn} do
    {:ok, item} = Item.create_item(%{text: "Get Fancy!", person_id: 1, status_code: 2})

    assert item.status_code == 2

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :start, %{"id" => item.id}) =~ "stop"
  end

  test "stop a timer", %{conn: conn} do
    {:ok, item} = Item.create_item(%{text: "Get Fancy!", person_id: 1, status_code: 2})

    assert item.status_code == 2
    started = NaiveDateTime.utc_now()
    {:ok, timer} = Timer.start(%{item_id: item.id, start: started})

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, :stop, 
      %{"id" => item.id, "timerid" => timer.id}) =~ "mind"
  end

  # This test is just to ensure coverage of the handle_info/2 function
  # It's not required but we like to have 100% coverage.
  # https://stackoverflow.com/a/60852290/1148249
  test "handle_info/2 start|stop", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} = Item.create_item(%{text: "Always Learning", person_id: 1, status_code: 2})
    started = NaiveDateTime.utc_now()
    {:ok, _timer} = Timer.start(%{item_id: item.id, start: started})

    send(view.pid, %{
      event: "start|stop",
      payload: %{items: Item.items_with_timers(1)}
    })

    assert render(view) =~ item.text
  end

  test "handle_info/2 update", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} = Item.create_item(%{text: "Always Learning", person_id: 1, status_code: 2})

    send(view.pid, %{
      event: "update",
      payload: %{items: Item.items_with_timers(1)}
    })

    assert render(view) =~ item.text
  end

  test "handle_info/2 delete", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} = Item.create_item(%{text: "Always Learning", person_id: 1, status_code: 6})

    send(view.pid, %{
      event: "delete",
      payload: %{items: Item.items_with_timers(1)}
    })

    refute render(view) =~ item.text
  end
end
