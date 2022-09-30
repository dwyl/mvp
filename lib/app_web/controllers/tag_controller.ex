defmodule AppWeb.TagController do
  use AppWeb, :controller
  alias App.Tag
  plug :loggedin

  def index(conn, _params) do
    person_id = conn.assigns[:person][:id] || 0
    tags = Tag.list_person_tags(person_id) |> IO.inspect()

    render(conn, "index.html", tags: tags)
  end

  defp loggedin(conn, _opts) do
    if not is_nil(conn.assigns[:jwt]) do
      assign(conn, :loggedin, true)
    else
      assign(conn, :loggedin, false)
    end
  end
end
