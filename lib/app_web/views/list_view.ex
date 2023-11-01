defmodule AppWeb.ListView do
  use AppWeb, :view

  def list_item_count(list) do
    if list.seq == nil do
      "0"
    else
      list.seq |> String.split(",") |> length |> to_string
    end
  end

  @doc """
  `title_case/1` convert "title case" string to "Title Case"
  ref: https://en.wikipedia.org/wiki/Letter_case#Title_case
  """
  def title_case(name) do
    name
    |> String.split()
    |> Enum.map_join(" ", &String.capitalize(&1))
  end

  def format_date(date) do
    App.DateTimeHelper.format_date(date)
  end
end
