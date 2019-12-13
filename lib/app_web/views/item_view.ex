defmodule AppWeb.ItemView do
  use AppWeb, :view

  def render("index.json", data) do
    Enum.map(data.items, fn i -> %{id: i.id, text: i.text} end)
  end
end
