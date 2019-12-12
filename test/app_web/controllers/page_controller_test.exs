defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "effectiveness"
  end

  describe "login/register" do
    test "display error when password invalid", %{conn: conn} do
      params = %{"person" => %{"email" => "test@email.com", "password" => "p"}}
      conn = post(conn, Routes.page_path(conn, :register), params)

      assert html_response(conn, 200) =~ "should be at least 6 character(s)"
    end

    test "redirects to home", %{conn: conn} do
      params = %{"person" => %{"email" => "test@email.com", "password" => "password"}}
      conn = post(conn, Routes.page_path(conn, :register), params)

      assert redirected_to(conn, 302) =~ "/people/info"
    end
  end
end
