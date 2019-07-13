defmodule AppWeb.TimerController do
  use AppWeb, :controller

  alias App.Ctx
  alias App.Ctx.Timer

  def index(conn, _params) do
    timers = Ctx.list_timers()
    render(conn, "index.html", timers: timers)
  end

  def new(conn, _params) do
    changeset = Ctx.change_timer(%Timer{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"timer" => timer_params}) do
    case Ctx.create_timer(timer_params) do
      {:ok, timer} ->
        conn
        |> put_flash(:info, "Timer created successfully.")
        |> redirect(to: Routes.timer_path(conn, :show, timer))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    timer = Ctx.get_timer!(id)
    render(conn, "show.html", timer: timer)
  end

  def edit(conn, %{"id" => id}) do
    timer = Ctx.get_timer!(id)
    changeset = Ctx.change_timer(timer)
    render(conn, "edit.html", timer: timer, changeset: changeset)
  end

  def update(conn, %{"id" => id, "timer" => timer_params}) do
    timer = Ctx.get_timer!(id)

    case Ctx.update_timer(timer, timer_params) do
      {:ok, timer} ->
        conn
        |> put_flash(:info, "Timer updated successfully.")
        |> redirect(to: Routes.timer_path(conn, :show, timer))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", timer: timer, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    timer = Ctx.get_timer!(id)
    {:ok, _timer} = Ctx.delete_timer(timer)

    conn
    |> put_flash(:info, "Timer deleted successfully.")
    |> redirect(to: Routes.timer_path(conn, :index))
  end
end
