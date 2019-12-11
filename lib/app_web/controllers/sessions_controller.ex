defmodule AppWeb.SessionController do
  use AppWeb, :controller

  def delete(conn, _params) do
    conn
    |> AppWeb.Auth.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
