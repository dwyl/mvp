defmodule AppWeb.CategoriseController do
  use AppWeb, :controller

  alias App.Ctx

  def index(conn, _) do
    captures = Ctx.list_items()
    render(conn, "index.html", captures: captures)
  end
end
