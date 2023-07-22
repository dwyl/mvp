defmodule App.DateHelper do
  def format_date(date) do
    Calendar.strftime(date, "%m/%d/%Y %H:%M:%S")
  end
end
