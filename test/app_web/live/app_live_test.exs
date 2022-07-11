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
    assert render_submit(view, :create, %{text: "Learn Elixir", person_id: 1}) =~ "Learn Elixir"
  end

  test "toggle an item", %{conn: conn} do
    {:ok, item} = Item.create_item(%{text: "Learn Elixir", person_id: 1, status_code: 2})
    assert item.status_code == 2

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :toggle, %{"id" => item.id, "value" => 4}) =~ "line-through"

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
    started = NaiveDateTime.utc_now
    {:ok, timer} = Timer.start(%{item_id: item.id, start: started})

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :stop, %{"id" => item.id, "timerid" => timer.id}) =~ "mind"
  end
end
