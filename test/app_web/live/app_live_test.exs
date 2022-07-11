defmodule AppWeb.AppLiveTest do
  use AppWeb.ConnCase
  alias App.{Item, Person, Status, Timer}
  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "mind"
    assert render(page_live) =~ "mind"
  end

  test "connect and create an item", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_submit(view, :create, %{text: "Learn Elixir", person_id: 1}) =~
             "Learn Elixir"
  end

  test "toggle an item", %{conn: conn} do
    person = Person.get_person!(1)
    status = Status.get_by_text!(:uncategorized)

    assert {:ok, item} =
             Item.create_item(%{text: "Learn Elixir"}, person, status)

    assert item.status.code == 2

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, :toggle, %{"id" => item.id, "value" => "on"}) =~
             "line-through"

    updated_item = Item.get_item!(item.id)
    assert updated_item.status.code == 4
  end

  test "(soft) delete an item", %{conn: conn} do
    person = Person.get_person!(1)
    status = Status.get_by_text!(:uncategorized)

    {:ok, item} = Item.create_item(%{text: "Learn Elixir"}, person, status)

    assert item.status.code == 2

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :delete, %{"id" => item.id}) =~ "mind"

    updated_item = Item.get_item!(item.id)
    assert updated_item.status.code == 6
  end

  test "start a timer", %{conn: conn} do
    person = Person.get_person!(1)
    status = Status.get_by_text!(:uncategorized)

    {:ok, item} = Item.create_item(%{text: "Get Fancy!"}, person, status)

    assert item.status.code == 2

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :start, %{"id" => item.id}) =~ "stop"
  end

  test "stop a timer", %{conn: conn} do
    person = Person.get_person!(1)
    status = Status.get_by_text!(:uncategorized)

    {:ok, item} = Item.create_item(%{text: "Get Fancy!"}, person, status)

    assert item.status.code == 2
    started = NaiveDateTime.utc_now()
    {:ok, timer} = Timer.start(%{item_id: item.id, start: started})

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, :stop, %{"id" => item.id, "timerid" => timer.id}) =~
             "mind"

    # timestamp = 
    # assert AppWeb.AppLive.timestamp(timer) ==
  end

  # This test is just to ensure coverage of the handle_info/2 function
  # It's not required but we like to have 100% coverage.
  # https://stackoverflow.com/a/60852290/1148249
  test "handle_info/2", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    person = Person.get_person!(1)
    status = Status.get_by_text!(:uncategorized)

    {:ok, item} = Item.create_item(%{text: "Always Learning"}, person, status)
    started = NaiveDateTime.utc_now()
    {:ok, timer} = Timer.start(%{item_id: item.id, start: started})

    send(view.pid, %{
      event: "start|stop",
      payload: %{items: Item.list_items(), timer: timer}
    })

    assert render(view) =~ item.text
  end
end
