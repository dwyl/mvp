defmodule AppWeb.ListView do
  use AppWeb, :view

  def list_item_count(list) do
    # dbg(list)
    if list.seq == nil do
      "0"
    else
      list.seq |> String.split(",") |> length |> to_string
    end
  end

  def format_date(date) do
    App.DateTimeHelper.format_date(date)
  end
end
