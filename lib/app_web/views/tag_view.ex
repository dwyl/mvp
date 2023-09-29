defmodule AppWeb.TagView do
  use AppWeb, :view
  alias App.DateTimeHelper

  def format_date(date) do
    DateTimeHelper.format_date(date)
  end
end
