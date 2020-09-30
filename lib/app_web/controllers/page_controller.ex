defmodule AppWeb.PageController do
  use AppWeb, :controller
  alias App.Person

  def index(conn, _params) do
    changeset = Person.changeset(%Person{}, %{})

    render(conn, "index.html", changeset: changeset)
  end
end
