defmodule AppWeb.TableComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(
      AppWeb.TableComponentView,
      "table_component.html",
      assigns
    )
  end
end
