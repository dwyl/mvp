ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(App.Repo, :manual)
# import Plug.Conn
import Phoenix.ConnTest

defmodule AppTest do
  def person_data do
    rand = :rand.uniform(1_000_000)

    %{
      email: "alex+#{rand}@gmail.com",
      givenName: "Alex",
      auth_provider: "email",
      picture: "https://avatars3.githubusercontent.com/u/10835816",
      status: 1,
      app_id: 42
    }
  end

  def create_person(data) do
    App.Person.create_person(data)
  end

  def create_person do
    data = person_data()
    create_person(data)
  end

  def person_login() do
    data = person_data()
    person = create_person(data)

    merged = Map.merge(data, %{id: person.id})
    # see: https://github.com/dwyl/auth/issues/83
    conn = build_conn(:get, "endpoint")
    |> init_test_session(%{})
    |> AuthPlug.create_jwt_session(merged)
    
    {:ok, conn: conn}
  end
end
