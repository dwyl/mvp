defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, params) do
    if Map.has_key?(conn.assigns, :person) do
      redirect(conn, to: AppWeb.Router.Helpers.item_path(conn, :new, params))
    else
      render(conn, "index.html")
    end
  end
end
