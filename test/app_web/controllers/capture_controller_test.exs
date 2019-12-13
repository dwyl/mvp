defmodule AppWeb.CaptureControllerTest do
  use AppWeb.ConnCase
  import App.SetupHelpers

  @create_attrs %{text: "some text"}
  @invalid_attrs %{text: nil}

  describe "new capture" do
    setup [:person_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.capture_path(conn, :new))
      assert html_response(conn, 200) =~ "Capture"
    end
  end

  describe "create capture" do
    setup [:person_login]

    test "redirects to categorise page when data is valid", %{conn: conn} do
      conn = post(conn, Routes.capture_path(conn, :create), item: @create_attrs)
      assert redirected_to(conn) == Routes.categorise_path(conn, :index)
    end


    test "api - create a new capture", %{conn: conn} do
      conn = post(conn, Routes.capture_path(conn, :api_create), item: @create_attrs)
      assert json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.capture_path(conn, :create), item: @invalid_attrs)

      assert html_response(conn, 200) =~ "Capture"
    end

    test "elm - render capture html page", %{conn: conn} do
      conn = get(conn, Routes.capture_path(conn, :init_elm))
      assert html_response(conn, 200)
    end
  end
end
