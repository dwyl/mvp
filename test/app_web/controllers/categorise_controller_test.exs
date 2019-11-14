defmodule AppWeb.CategoriseControllerTest do
  use AppWeb.ConnCase

  describe "return captured text" do
    test "index page for categorise", %{conn: conn} do
      conn = get(conn, Routes.categorise_path(conn, :index))
      assert redirected_to(conn) == Routes.item_path(conn, :index)
    end
  end

end
