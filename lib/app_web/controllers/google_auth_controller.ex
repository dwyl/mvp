defmodule AppWeb.GoogleAuthController do
  use AppWeb, :controller

  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code)
    profile = ElixirAuthGoogle.get_user_profile(token["access_token"])
    IO.inspect profile
    redirect(conn, to: "/")
  end
end
