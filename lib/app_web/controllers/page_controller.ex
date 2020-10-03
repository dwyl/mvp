defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
    changeset = Person.changeset(%App.Person{}, %{})

    render(conn, "index.html", changeset: changeset)
  end
end
