defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "effectiveness"
  end

  describe "login/register and logout" do
    test "display error when password invalid", %{conn: conn} do
      params = %{"person" => %{"email" => "test@email.com", "password" => "p"}}
      conn = post(conn, Routes.page_path(conn, :register), params)

      assert html_response(conn, 200) =~ "should be at least 6 character(s)"
    end

    test "redirects to user info page when already logged in", %{conn: conn} do
      params = %{"person" => %{"email" => "test@email.com", "password" => "password"}}
      conn = post(conn, Routes.page_path(conn, :register), params)

      assert redirected_to(conn, 302) =~ "/people/info"
    end

    test "on logout redirect to index (ie / ) page", %{conn: conn} do
      params = %{"person" => %{"email" => "test@email.com", "password" => "password"}}
      conn = post(conn, Routes.page_path(conn, :register), params)
      conn = get(conn, Routes.person_path(conn, :logout))
      assert redirected_to(conn, 302) =~ "/"
    end
  end
end
