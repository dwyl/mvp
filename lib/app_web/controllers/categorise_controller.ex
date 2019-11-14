defmodule AppWeb.CategoriseController do
  use AppWeb, :controller

  def index(conn, _) do
    redirect(conn, to: Routes.item_path(conn, :index))
  end
end
