defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase
  import App.SetupHelpers

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "effectiveness"
  end

  describe "GET / (homepage) when logged-in shows /items/new" do
    setup [:person_login]

    test "redirects to the new item form form", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 302) =~ "redirected"
    end
  end
end
