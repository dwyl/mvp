defmodule AppWeb.NavView do
  use AppWeb, :view

  # Avoid duplicating Tailwind classes and show hot to inline a function call:
  # defp btn(color) do
  #   "text-6xl pb-2 w-20 rounded-lg bg-#{color}-500 hover:bg-#{color}-600"
  # end
  def list_url(cid) do
    "/?list_cid=" <> cid
  end

  def list_name(name) do
    name = if name == "all", do: "📥 All", else: name
    AppWeb.ListView.title_case(name)
  end
end
