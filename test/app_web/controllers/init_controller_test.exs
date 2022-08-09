defmodule AppWeb.InitControllerTest do
  use AppWeb.ConnCase, async: true

  test "GET /init init (status) page", %{conn: conn} do
    conn = get(conn, Routes.init_path(conn, :index))
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body =~ "REQUIRED Environment Variable"
  end
end
