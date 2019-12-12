defmodule AppWeb.CaptureController do
  use AppWeb, :controller

  alias App.Ctx
  alias App.Ctx.Item

  def new(conn, _params) do
    changeset = Ctx.change_item(%Item{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item" => capture_params}) do
    case Ctx.create_item(capture_params) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: Routes.categorise_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def api_create(conn, %{"text" => capture}) do
    case Ctx.create_item(%{text: capture}) do
      {:ok, item} ->
        render(conn, "capture.json", item: %{text: item.text})

      {:error, _} ->
        error = %{error: "The capture cannot be saved."}
        render(conn, "capture_error.json", err: error)
    end
  end

  def api_create(conn, _params) do
    error = %{error: "text field is not defined"}
    render(conn, "capture_error.json", err: error)
  end
end
