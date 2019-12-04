defmodule App.SetupHelpers do
  use Phoenix.ConnTest
  import AppWeb.Router.Helpers

  @endpoint AppWeb.Endpoint

  def person_login(_) do
    {:ok,
     conn:
      build_conn()
          |> (fn c ->
             get(c, google_auth_path(c, :index, code: "code"))
          end).()
    }
  end

end
