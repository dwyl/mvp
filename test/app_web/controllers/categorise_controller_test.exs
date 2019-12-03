defmodule AppWeb.CategoriseControllerTest do
  use AppWeb.ConnCase
  import App.SetupHelpers

  describe "return captured text" do
    setup [:person_login]
    test "index page for categorise", %{conn: conn} do
      conn = get(conn, Routes.categorise_path(conn, :index))
      assert html_response(conn, 200) =~ "Captures"
    end
  end

end
