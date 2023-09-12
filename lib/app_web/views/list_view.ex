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
end
