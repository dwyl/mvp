defmodule AppWeb.InitController do
  use AppWeb, :controller
  require Logger

  @env_required ~w/AUTH_API_KEY ENCRYPTION_KEYS SECRET_KEY_BASE DATABASE_URL/

  def index(conn, _params) do
    Logger.info("init attempting to check environment variables ... ")

    conn
    |> assign(:loggedin, true)
    |> assign(:person, %{picture: "https://dwyl.com/img/favicon-32x32.png"})
    |> render(:index,
      env: check_env(@env_required),
      api_key_set: api_key_set?()
    )
  end

  defp check_env(keys) do
    Enum.reduce(keys, %{}, fn key, acc ->
      Map.put(acc, key, Envar.is_set?(key))
    end)
  end

  defp api_key_set?() do
    case AuthPlug.Token.api_key() do
      # coveralls-ignore-start
      nil ->
        # IO.puts("AuthPlug.Token.api_key() #{AuthPlug.Token.api_key()}")
        false

      # coveralls-ignore-stop

      key ->
        String.length(key) > 1
    end
  end
end
