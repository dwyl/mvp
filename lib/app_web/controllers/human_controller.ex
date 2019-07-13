defmodule AppWeb.HumanController do
  use AppWeb, :controller

  alias App.Ctx
  alias App.Ctx.Human

  def index(conn, _params) do
    humans = Ctx.list_humans()
    render(conn, "index.html", humans: humans)
  end

  def new(conn, _params) do
    changeset = Ctx.change_human(%Human{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"human" => human_params}) do
    case Ctx.create_human(human_params) do
      {:ok, human} ->
        conn
        |> put_flash(:info, "Human created successfully.")
        |> redirect(to: Routes.human_path(conn, :show, human))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    human = Ctx.get_human!(id)
    render(conn, "show.html", human: human)
  end

  def edit(conn, %{"id" => id}) do
    human = Ctx.get_human!(id)
    changeset = Ctx.change_human(human)
    render(conn, "edit.html", human: human, changeset: changeset)
  end

  def update(conn, %{"id" => id, "human" => human_params}) do
    human = Ctx.get_human!(id)

    case Ctx.update_human(human, human_params) do
      {:ok, human} ->
        conn
        |> put_flash(:info, "Human updated successfully.")
        |> redirect(to: Routes.human_path(conn, :show, human))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", human: human, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    human = Ctx.get_human!(id)
    {:ok, _human} = Ctx.delete_human(human)

    conn
    |> put_flash(:info, "Human deleted successfully.")
    |> redirect(to: Routes.human_path(conn, :index))
  end
end
