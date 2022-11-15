defmodule AppWeb.AppLiveTest do
  use AppWeb.ConnCase
  alias App.{Item, Person, Timer, Tag}
  import Phoenix.LiveViewTest
  alias Phoenix.Socket.Broadcast

  setup [:create_person]

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "done"
    assert render(page_live) =~ "done"
  end

  test "connect and create an item", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_submit(view, :create, %{
             text: "Learn Elixir",
             person_id: nil,
             tags: ""
           })
  end

  test "toggle an item", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: 0})

    {:ok, _item2} =
      Item.create_item(%{text: "Learn Elixir", status: 4, person_id: 0})

    assert item.status == 2

    started = NaiveDateTime.utc_now()
    {:ok, _timer} = Timer.start(%{item_id: item.id, start: started})

    # See: https://github.com/dwyl/useful/issues/17#issuecomment-1186070198
    # assert Useful.typeof(:timer_id) == "atom"
    assert Item.items_with_timers(1) > 0

    {:ok, view, _html} = live(conn, "/?filter_by=all")

    assert render_click(view, :toggle, %{"id" => item.id, "value" => "on"}) =~
             "line-through"

    updated_item = Item.get_item!(item.id)
    assert updated_item.status == 4
  end

  test "(soft) delete an item", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    assert item.status == 2

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :delete, %{"id" => item.id}) =~ "done"

    updated_item = Item.get_item!(item.id)
    assert updated_item.status == 6
  end

  test "start a timer", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Get Fancy!", person_id: 0, status: 2})

    assert item.status == 2

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :start, %{"id" => item.id})
  end

  test "stop a timer", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Get Fancy!", person_id: 0, status: 2})

    assert item.status == 2
    started = NaiveDateTime.utc_now()
    {:ok, timer} = Timer.start(%{item_id: item.id, start: started})

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, :stop, %{"id" => item.id, "timerid" => timer.id}) =~
             "done"
  end

  test "handle_info/2 update", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} =
      Item.create_item(%{text: "Always Learning", person_id: 0, status: 2})

    send(view.pid, %Broadcast{
      event: "update",
      payload: :create
    })

    assert render(view) =~ item.text
  end

  test "handle_info/2 update with editing open (start)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} =
      Item.create_item(%{text: "Always Learning", person_id: 0, status: 2})

    {:ok, now} = NaiveDateTime.new(Date.utc_today(), Time.utc_now())

    now_string =
      NaiveDateTime.truncate(now, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})
    render_click(view, "start", %{"id" => Integer.to_string(item.id)})

    # The editing panel is open and showing the newly created timer on the 'Start' text input field
    assert render(view) =~ now_string
  end

  test "handle_info/2 update with editing open (stop)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} =
      Item.create_item(%{text: "Always Learning", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})
    render_click(view, "start", %{"id" => Integer.to_string(item.id)})
    render_click(view, "stop", %{"timerid" => timer.id, "id" => item.id})

    num_timers_rendered =
      (render(view) |> String.split("Update") |> length()) - 1

    # Checking if two timers were rendered
    assert num_timers_rendered == 2
  end

  test "handle_info/2 update with editing open (delete)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} =
      Item.create_item(%{text: "Always Learning", person_id: 0, status: 2})

    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    send(view.pid, %Broadcast{
      event: "update",
      payload: :delete
    })

    assert render(view) =~ item.text
  end

  test "edit-item", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)}) =~
             "<form phx-submit=\"update-item\" id=\"form-update"
  end

  test "update an item", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, view, _html} = live(conn, "/")

    assert render_submit(view, "update-item", %{
             "id" => item.id,
             "text" => "Learn more Elixir",
             "tags" => "Learn, Elixir"
           })

    updated_item = Item.get_item!(item.id)
    assert updated_item.text == "Learn more Elixir"
    assert length(updated_item.tags) == 2
  end

  test "update an item's timer", %{conn: conn} do
    start = "2022-10-27T00:00:00"
    stop = "2022-10-27T05:00:00"
    start_datetime = ~N[2022-10-27 00:00:00]
    stop_datetime = ~N[2022-10-27 05:00:00]

    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    {:ok, view, _html} = live(conn, "/")

    # Update successful
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => start,
             "timer_stop" => stop
           })

    updated_timer = Timer.get_timer!(timer.id)

    assert updated_timer.start == start_datetime
    assert updated_timer.stop == stop_datetime

    # Trying to update with equal values on start and stop
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => start,
             "timer_stop" => start
           }) =~ "Start or stop are equal."

    # Trying to update with equal start greater than stop
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => stop,
             "timer_stop" => start
           }) =~ "Start is newer that stop."

    # Trying to update with start as invalid format
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => "invalid",
             "timer_stop" => stop
           }) =~ "Start field has an invalid date format."

    # Trying to update with stop as invalid format
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => start,
             "timer_stop" => "invalid"
           }) =~ "Stop field has an invalid date format."
  end

  test "update timer timer with ongoing timer ", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    {:ok, now} = NaiveDateTime.new(Date.utc_today(), Time.utc_now())

    {:ok, four_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -4))

    {:ok, ten_seconds_after} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), 10))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    # Start a second timer
    {:ok, timer2} = Timer.start(%{item_id: item.id, person_id: 1, start: now})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    {:ok, view, _html} = live(conn, "/")

    # Update fails because of overlap timer -----------
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    four_seconds_ago_string =
      NaiveDateTime.truncate(four_seconds_ago, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    now_string =
      NaiveDateTime.truncate(now, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    error_view =
      render_submit(view, "update-item-timer", %{
        "timer_id" => timer2.id,
        "index" => 1,
        "timer_start" => four_seconds_ago_string,
        "timer_stop" => ""
      })

    assert error_view =~ "When editing an ongoing timer"

    # Update fails because of format -----------
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    error_format_view =
      render_submit(view, "update-item-timer", %{
        "timer_id" => timer2.id,
        "index" => 1,
        "timer_start" => "invalidformat",
        "timer_stop" => ""
      })

    assert error_format_view =~ "Start field has an invalid date format."

    # Update successful -----------
    ten_seconds_after_string =
      NaiveDateTime.truncate(ten_seconds_after, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    ten_seconds_after_datetime =
      NaiveDateTime.truncate(ten_seconds_after, :second)

    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    view =
      assert render_submit(view, "update-item-timer", %{
               "timer_id" => timer2.id,
               "index" => 1,
               "timer_start" => ten_seconds_after_string,
               "timer_stop" => ""
             })

    updated_timer2 = Timer.get_timer!(timer2.id)

    assert updated_timer2.start == ten_seconds_after_datetime
  end

  test "timer overlap error when updating timer", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    {:ok, now} = NaiveDateTime.new(Date.utc_today(), Time.utc_now())

    {:ok, four_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -4))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    # Start a second timer
    {:ok, timer2} = Timer.start(%{item_id: item.id, person_id: 1, start: now})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    {:ok, view, _html} = live(conn, "/")

    # Update fails because of overlap -----------
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    four_seconds_ago_string =
      NaiveDateTime.truncate(four_seconds_ago, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    now_string =
      NaiveDateTime.truncate(now, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer2.id,
             "index" => 0,
             "timer_start" => four_seconds_ago_string,
             "timer_stop" => now_string
           }) =~ "This timer interval overlaps with other timers."
  end

  test "timer_text(start, stop)" do
    timer = %{
      start: ~N[2022-07-17 09:01:42.000000],
      stop: ~N[2022-07-17 13:22:24.000000]
    }

    assert AppWeb.AppLive.timer_text(timer) == "04:20:42"
  end

  test "filter items", %{conn: conn} do
    {:ok, _item} =
      Item.create_item(%{text: "Item to do", person_id: 0, status: 2})

    {:ok, _item_done} =
      Item.create_item(%{text: "Item done", person_id: 0, status: 4})

    {:ok, _item_archived} =
      Item.create_item(%{text: "Item archived", person_id: 0, status: 6})

    {:ok, view, _html} = live(conn, "/?filter_by=all")
    assert render(view) =~ "Item to do"
    assert render(view) =~ "Item done"
    assert render(view) =~ "Item archived"

    {:ok, view, _html} = live(conn, "/?filter_by=active")
    assert render(view) =~ "Item to do"
    refute render(view) =~ "Item done"
    refute render(view) =~ "Item archived"

    {:ok, view, _html} = live(conn, "/?filter_by=done")
    refute render(view) =~ "Item to do"
    assert render(view) =~ "Item done"
    refute render(view) =~ "Item archived"

    {:ok, view, _html} = live(conn, "/?filter_by=archived")
    refute render(view) =~ "Item to do"
    refute render(view) =~ "Item done"
    assert render(view) =~ "Item archived"
  end

  test "filter items by tag name", %{conn: conn} do
    {:ok, _item} =
      Item.create_item_with_tags(%{
        text: "Item1 to do",
        person_id: 0,
        status: 2,
        tags: "tag1, tag2"
      })

    {:ok, _item} =
      Item.create_item_with_tags(%{
        text: "Item2 to do",
        person_id: 0,
        status: 2,
        tags: "tag1, tag3"
      })

    {:ok, view, _html} = live(conn, "/?filter_by=all")
    assert render(view) =~ "Item1 to do"
    assert render(view) =~ "Item2 to do"

    {:ok, view, _html} = live(conn, "/?filter_by=all&filter_by_tag=tag2")
    assert render(view) =~ "Item1 to do"
    refute render(view) =~ "Item2 to do"

    {:ok, view, _html} = live(conn, "/?filter_by=all&filter_by_tag=tag3")
    refute render(view) =~ "Item1 to do"
    assert render(view) =~ "Item2 to do"

    {:ok, view, _html} = live(conn, "/?filter_by=all&filter_by_tag=tag1")
    assert render(view) =~ "Item1 to do"
    assert render(view) =~ "Item2 to do"
  end

  test "get / with valid JWT", %{conn: conn} do
    data = %{
      email: "test@dwyl.com",
      givenName: "Alex",
      picture: "this",
      auth_provider: "GitHub",
      id: 0
    }

    jwt = AuthPlug.Token.generate_jwt!(data)

    {:ok, view, _html} = live(conn, "/?jwt=#{jwt}")
    assert render(view)
  end

  test "Logout link displayed when loggedin", %{conn: conn} do
    data = %{
      email: "test@dwyl.com",
      givenName: "Alex",
      picture: "this",
      auth_provider: "GitHub",
      id: 0
    }

    jwt = AuthPlug.Token.generate_jwt!(data)

    conn = get(conn, "/?jwt=#{jwt}")
    assert html_response(conn, 200) =~ "logout"
  end

  test "get /logout with valid JWT", %{conn: conn} do
    data = %{
      email: "test@dwyl.com",
      givenName: "Alex",
      picture: "this",
      auth_provider: "GitHub",
      sid: 1,
      id: 0
    }

    jwt = AuthPlug.Token.generate_jwt!(data)

    conn =
      conn
      |> put_req_header("authorization", jwt)
      |> get("/logout")

    assert "/" = redirected_to(conn, 302)
  end

  test "test login link redirect to auth.dwyl.com", %{conn: conn} do
    conn = get(conn, "/login")

    assert redirected_to(conn, 302) =~ "auth.dwyl.com"
  end

  test "tags_to_string/1" do
    assert AppWeb.AppLive.tags_to_string([
             %Tag{text: "Learn"},
             %Tag{text: "Elixir"}
           ]) == "Learn, Elixir"
  end

  defp create_person(_) do
    person = Person.create_person(%{"person_id" => 0, "name" => "guest"})
    %{person: person}
  end
end
