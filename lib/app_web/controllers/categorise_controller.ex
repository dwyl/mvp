defmodule AppWeb.CategoriseController do
  use AppWeb, :controller

  def index(conn, _) do
    captures = App.Item.list_items()
    render(conn, "index.html", captures: captures)
  end
end
