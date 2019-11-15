defmodule AppWeb.CategoriseControllerTest do
  use AppWeb.ConnCase

  describe "return captured text" do
    test "index page for categorise", %{conn: conn} do
      conn = get(conn, Routes.categorise_path(conn, :index))
      assert html_response(conn, 200) =~ "Captures"
    end
  end

end
