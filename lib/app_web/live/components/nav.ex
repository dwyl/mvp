defmodule AppWeb.Nav do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(AppWeb.NavView, "nav.html", assigns)
  end
end
