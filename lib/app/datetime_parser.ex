# Full credit of this module goes to https://dev.to/onpointvn/build-your-own-date-time-parser-in-elixir-50be
# Do check the gist -> https://gist.github.com/bluzky/62a20cdb57b17f47c67261c10aa3da8b
defmodule App.DateTimeParser do
  @mapping %{
    "H" => "(?<hour>\\d{2})",
    "I" => "(?<hour12>\\d{2})",
    "M" => "(?<minute>\\d{2})",
    "S" => "(?<second>\\d{2})",
    "d" => "(?<day>\\d{2})",
    "m" => "(?<month>\\d{2})",
    "y" => "(?<year2>\\d{2})",
    "Y" => "(?<year>-?\\d{4})",
    "z" => "(?<tz>[+-]?\\d{4})",
    "Z" => "(?<tz_name>[a-zA-Z_\/]+)",
    "p" => "(?<p>PM|AM)",
    "P" => "(?<P>pm|am)",
    "%" => "%"
  }

  @doc """
  Parse string to datetime struct
  **Example**
      parse("2021-20-10", "%Y-%M-%d")
  Support format
  | format | description| value example |
  | -- | -- | -- |
  | H | 24 hour | 00 - 23 |
  | I | 12 hour | 00 - 12 |
  | M | minute| 00 - 59 |
  | S | second | 00 - 59 |
  | d | day | 01 - 31 |
  | m | month | 01 -12 |
  | y | 2 digits year | 00 - 99 |
  | Y | 4 digits year | |
  | z | timezone offset | +0100, -0330 |
  | Z | timezone name | UTC+7, Asia/Ho_Chi_Minh |
  | p | PM or AM | |
  | P | pm or am | |
  """
  def parse!(dt_string, format \\ "%Y-%m-%dT%H:%M:%SZ") do
    case parse(dt_string, format) do
      {:ok, dt} ->
        dt

      {:error, message} ->
        raise "Parse string #{dt_string} with error: #{message}"
    end
  end

  @doc """
  Parses the string according to the format. Pipes through regex compilation, casts each part of the string to a named regex capture and tries to convert to datetime.
  """
  def parse(dt_string, format \\ "%Y-%m-%dT%H:%M:%SZ") do
    format
    |> build_regex
    |> Regex.named_captures(dt_string)
    |> cast_data
    |> to_datetime
  end

  def build_regex(format) do
    keys = Map.keys(@mapping) |> Enum.join("")

    Regex.compile!("([^%]*)%([#{keys}])([^%]*)")
    |> Regex.scan(format)
    |> Enum.map(fn [_, s1, key, s2] ->
      [s1, Map.get(@mapping, key), s2]
    end)
    |> to_string()
    |> Regex.compile!()
  end

  @default_value %{
    day: 1,
    month: 1,
    year: 0,
    hour: 0,
    minute: 0,
    second: 0,
    utc_offset: 0,
    tz_name: "UTC",
    shift: "AM"
  }
  def cast_data(nil), do: {:error, "invalid datetime"}

  def cast_data(captures) do
    captures
    |> Enum.reduce_while([], fn {part, value}, acc ->
      {:ok, data} = cast(part, value)
      {:cont, [data | acc]}
    end)
    |> Enum.into(@default_value)
  end

  @value_rages %{
    "hour" => [0, 23],
    "hour12" => [0, 12],
    "minute" => [0, 59],
    "second" => [0, 59],
    "day" => [0, 31],
    "month" => [1, 12],
    "year2" => [0, 99]
  }

  defp cast("P", value) do
    cast("p", String.upcase(value))
  end

  defp cast("p", value) do
    {:ok, {:shift, value}}
  end

  defp cast("tz", value) do
    {hour, minute} = String.split_at(value, 3)

    with {:ok, {_, hour}} <- cast("offset_h", hour),
         {:ok, {_, minute}} <- cast("offset_m", minute) do
      sign = div(hour, abs(hour))
      {:ok, {:utc_offset, sign * (abs(hour) * 3600 + minute * 60)}}
    end
  end

  defp cast("tz_name", value) do
    {:ok, {:tz_name, value}}
  end

  defp cast(part, value) do
    value = String.to_integer(value)

    valid =
      case Map.get(@value_rages, part) do
        [min, max] ->
          value >= min and value <= max

        _ ->
          true
      end

    if valid do
      {:ok, {String.to_atom(part), value}}
    end
  end

  defp to_datetime({:error, _} = error), do: error

  defp to_datetime(%{year2: value} = data) do
    current_year = DateTime.utc_now() |> Map.get(:year)
    year = div(current_year, 100) * 100 + value

    data
    |> Map.put(:year, year)
    |> Map.delete(:year2)
    |> to_datetime()
  end

  defp to_datetime(%{hour12: hour} = data) do
    # 12AM is not valid

    if hour == 12 and data.shift == "AM" do
      {:error, "12AM is invalid value"}
    else
      hour =
        cond do
          hour == 12 and data.shift == "PM" -> hour
          data.shift == "AM" -> hour
          data.shift == "PM" -> hour + 12
        end

      data
      |> Map.put(:hour, hour)
      |> Map.delete(:hour12)
      |> to_datetime()
    end
  end

  defp to_datetime(data) do
    with {:ok, date} <- Date.new(data.year, data.month, data.day),
         {:ok, time} <- Time.new(data.hour, data.minute, data.second),
         {:ok, datetime} <- DateTime.new(date, time) do
      datetime = DateTime.add(datetime, -data.utc_offset, :second)

      if data.tz_name != "UTC" do
        {:error, "Only UTC timezone is available"}
      else
        {:ok, datetime}
      end
    end
  end
end
