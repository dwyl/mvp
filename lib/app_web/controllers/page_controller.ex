defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
    url_oauth_google = ElixirAuthGoogle.login_url()
    IO.inspect(url_oauth_google)
    render(conn, "index.html")
  end
end
