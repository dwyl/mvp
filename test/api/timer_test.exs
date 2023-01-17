defmodule API.TimerTest do
  use AppWeb.ConnCase
  alias App.Timer
  alias App.Item

  @create_item_attrs %{person_id: 42, status: 0, text: "some text"}

  @create_attrs %{item_id: 42, start: "2022-10-27T00:00:00"}
  @update_attrs %{item_id: 43, start: "2022-10-28T00:00:00"}
  @invalid_attrs %{item_id: nil, start: nil}

  describe "index" do
    test "timers", %{conn: conn} do
      # Create item and timer
      {item, _timer} = item_and_timer_fixture()

      conn = get(conn, Routes.timer_path(conn, :index, item.id))

      assert conn.status == 200
      assert length(json_response(conn, 200)) == 1
    end
  end

  describe "show" do
    test "specific timer", %{conn: conn} do
      # Create item and timer
      {item, timer} = item_and_timer_fixture()

      conn = get(conn, Routes.timer_path(conn, :show, item.id, timer.id))

      assert conn.status == 200
      assert json_response(conn, 200)["id"] == timer.id
    end

    test "not found timer", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      conn = get(conn, Routes.timer_path(conn, :show, item.id, -1))

      assert conn.status == 404
    end

    test "invalid id (not being an integer)", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      conn = get(conn, Routes.timer_path(conn, :show, item.id, "invalid"))
      assert conn.status == 400
    end
  end

  describe "create" do
    test "a valid timer", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      # Create timer
      conn =
        post(conn, Routes.timer_path(conn, :create, item.id, @create_attrs))

      assert conn.status == 200

      assert json_response(conn, 200)["start"] ==
               Map.get(@create_attrs, "start")
    end

    test "an invalid timer", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      conn =
        post(conn, Routes.timer_path(conn, :create, item.id, @invalid_attrs))

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["start"]) > 0
    end

    test "a timer with empty body", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      conn = post(conn, Routes.timer_path(conn, :create, item.id, %{}))

      assert conn.status == 200
    end
  end

  describe "stop" do
    test "timer without any attributes", %{conn: conn} do
      # Create item and timer
      {item, timer} = item_and_timer_fixture()

      conn =
        put(
          conn,
          Routes.timer_path(conn, :stop, timer.id, %{})
        )

      assert conn.status == 200
    end

    test "timer that doesn't exist", %{conn: conn} do
      conn = put(conn, Routes.timer_path(conn, :stop, -1, %{}))

      assert conn.status == 404
    end

    test "timer that has already stopped", %{conn: conn} do
      # Create item and timer
      {_item, timer} = item_and_timer_fixture()

      # Stop timer
      now = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()
      {:ok, timer} = Timer.update_timer(timer, %{stop: now})

      conn =
        put(
          conn,
          Routes.timer_path(conn, :stop, timer.id, %{})
        )

      assert conn.status == 403
    end
  end

  describe "update" do
    test "timer with valid attributes", %{conn: conn} do
      # Create item and timer
      {item, timer} = item_and_timer_fixture()

      conn =
        put(
          conn,
          Routes.timer_path(conn, :update, item.id, timer.id, @update_attrs)
        )

      assert conn.status == 200
      assert json_response(conn, 200)["start"] == Map.get(@update_attrs, :start)
    end

    test "timer with invalid attributes", %{conn: conn} do
      # Create item and timer
      {item, timer} = item_and_timer_fixture()

      conn =
        put(
          conn,
          Routes.timer_path(conn, :update, item.id, timer.id, @invalid_attrs)
        )

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["start"]) > 0
    end

    test "timer that doesn't exist", %{conn: conn} do
      conn = put(conn, Routes.timer_path(conn, :update, -1, -1, @invalid_attrs))

      assert conn.status == 404
    end
  end

  defp item_and_timer_fixture() do
    # Create item
    {:ok, %{model: item, version: _version}} =
      Item.create_item(@create_item_attrs)

    # Create timer
    started = NaiveDateTime.utc_now()
    {:ok, timer} = Timer.start(%{item_id: item.id, start: started})

    {item, timer}
  end
end
