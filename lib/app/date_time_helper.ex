defmodule App.DateTimeHelper do
  require Decimal
  alias Timex.{Duration}

  def format_date(date) do
    Calendar.strftime(date, "%m/%d/%Y %H:%M:%S")
  end

  def format_duration(nil), do: ""

  def format_duration(seconds) when Decimal.is_decimal(seconds) do
    duration = seconds |> Decimal.to_integer() |> Duration.from_seconds()

    Timex.format_duration(duration, :humanized)
  end
end
