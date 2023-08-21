defmodule AppWeb.TableComponentView do
  use AppWeb, :view

  def render_arrow_down() do
    Phoenix.View.render(AppWeb.TableComponentView, "arrow_down.html", %{})
  end

  def render_arrow_up() do
    Phoenix.View.render(AppWeb.TableComponentView, "arrow_up.html", %{
      invisible: false
    })
  end

  def render_arrow_up(:invisible) do
    Phoenix.View.render(AppWeb.TableComponentView, "arrow_up.html", %{
      invisible: true
    })
  end
end
