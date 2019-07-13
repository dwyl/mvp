defmodule AppWeb.KindController do
  use AppWeb, :controller

  alias App.Ctx
  alias App.Ctx.Kind

  def index(conn, _params) do
    kinds = Ctx.list_kinds()
    render(conn, "index.html", kinds: kinds)
  end

  def new(conn, _params) do
    changeset = Ctx.change_kind(%Kind{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"kind" => kind_params}) do
    case Ctx.create_kind(kind_params) do
      {:ok, kind} ->
        conn
        |> put_flash(:info, "Kind created successfully.")
        |> redirect(to: Routes.kind_path(conn, :show, kind))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    kind = Ctx.get_kind!(id)
    render(conn, "show.html", kind: kind)
  end

  def edit(conn, %{"id" => id}) do
    kind = Ctx.get_kind!(id)
    changeset = Ctx.change_kind(kind)
    render(conn, "edit.html", kind: kind, changeset: changeset)
  end

  def update(conn, %{"id" => id, "kind" => kind_params}) do
    kind = Ctx.get_kind!(id)

    case Ctx.update_kind(kind, kind_params) do
      {:ok, kind} ->
        conn
        |> put_flash(:info, "Kind updated successfully.")
        |> redirect(to: Routes.kind_path(conn, :show, kind))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", kind: kind, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    kind = Ctx.get_kind!(id)
    {:ok, _kind} = Ctx.delete_kind(kind)

    conn
    |> put_flash(:info, "Kind deleted successfully.")
    |> redirect(to: Routes.kind_path(conn, :index))
  end
end
