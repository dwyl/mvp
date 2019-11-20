defmodule AppWeb.GoogleAuthController do
  use AppWeb, :controller

  def index(conn, %{"code" => code}) do
    token = ElixirAuthGoogle.get_token(code)
    profile = ElixirAuthGoogle.get_user_profile(token["access_token"])
    redirect(conn, to: "/")
  end
end
