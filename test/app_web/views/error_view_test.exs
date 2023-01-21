defmodule AppWeb.ErrorViewTest do
  use AppWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(AppWeb.ErrorView, "404.html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(AppWeb.ErrorView, "500.html", []) ==
             "Internal Server Error"
  end

  test "testing error view with `Accept` header with `application/json` and passing a `.json` template" do
    assigns = %{reason: %{message: "Route not found."}}

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> Map.put(:assigns, assigns)

    conn = %{conn: conn}

    assert Jason.decode!(render_to_string(AppWeb.ErrorView, "404.json", conn)) ==
             %{"error" => "Route not found."}
  end

  test "testing error view with `Content-type` header with `application/json` and passing a `.json` template" do
    assigns = %{reason: %{message: "Route not found."}}

    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> Map.put(:assigns, assigns)

    conn = %{conn: conn}

    assert Jason.decode!(render_to_string(AppWeb.ErrorView, "404.json", conn)) ==
             %{"error" => "Route not found."}
  end

  test "testing error view with `Content-type` header with `application/json` and passing a `.html` template" do
    assigns = %{reason: %{message: "Route not found."}}

    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> Map.put(:assigns, assigns)

    conn = %{conn: conn}

    resp_body = Map.get(render(AppWeb.ErrorView, "404.html", conn), :resp_body)

    assert Jason.decode!(resp_body) == %{"error" => "Route not found."}
  end

  test "testing error view and passing a `.html` template" do
    conn = build_conn()
    conn = %{conn: conn}

    assert render_to_string(AppWeb.ErrorView, "404.html", conn) == "Not Found"
  end
end
