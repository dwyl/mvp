defmodule AppWeb.TimerControllerTest do
  use AppWeb.ConnCase
  import App.SetupHelpers
  alias App.Ctx

  @create_attrs %{end: ~N[2010-04-17 14:00:00], start: ~N[2010-04-17 14:00:00]}
  @update_attrs %{end: ~N[2011-05-18 15:01:01], start: ~N[2011-05-18 15:01:01]}
  @invalid_attrs %{end: nil, start: nil}

  def fixture(:timer) do
    {:ok, timer} = Ctx.create_timer(@create_attrs)
    timer
  end

  describe "index" do
    setup [:person_login]

    test "lists all timers", %{conn: conn} do
      conn = get(conn, Routes.timer_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Timers"
    end
  end

  describe "new timer" do
    setup [:person_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.timer_path(conn, :new))
      assert html_response(conn, 200) =~ "New Timer"
    end
  end

  describe "create timer" do
    setup [:person_login]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.timer_path(conn, :create), timer: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.timer_path(conn, :show, id)

      conn = get(conn, Routes.timer_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Timer"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.timer_path(conn, :create), timer: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Timer"
    end
  end

  describe "edit timer" do
    setup [:person_login, :create_timer]

    test "renders form for editing chosen timer", %{conn: conn, timer: timer} do
      conn = get(conn, Routes.timer_path(conn, :edit, timer))
      assert html_response(conn, 200) =~ "Edit Timer"
    end
  end

  describe "update timer" do
    setup [:person_login, :create_timer]

    test "redirects when data is valid", %{conn: conn, timer: timer} do
      conn = put(conn, Routes.timer_path(conn, :update, timer), timer: @update_attrs)
      assert redirected_to(conn) == Routes.timer_path(conn, :show, timer)

      conn = get(conn, Routes.timer_path(conn, :show, timer))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, timer: timer} do
      conn = put(conn, Routes.timer_path(conn, :update, timer), timer: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Timer"
    end
  end

  describe "delete timer" do
    setup [:person_login, :create_timer]

    test "deletes chosen timer", %{conn: conn, timer: timer} do
      conn = delete(conn, Routes.timer_path(conn, :delete, timer))
      assert redirected_to(conn) == Routes.timer_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.timer_path(conn, :show, timer))
      end
    end
  end

  defp create_timer(_) do
    timer = fixture(:timer)
    {:ok, timer: timer}
  end
end
