defmodule App.DateTimeParserTest do
  use App.DataCase
  alias App.DateTimeParser

  test "valid parse of valid datetime" do
    parsed_time =
      DateTimeParser.parse!("2022-10-27 14:47:56", "%Y-%m-%d %H:%M:%S")

    {:ok, expected_datetime, 0} = DateTime.from_iso8601("2022-10-27T14:47:56Z")

    assert parsed_time == expected_datetime
  end

  test "valid parse of valid date with %Y-%m-%d format" do
    parsed_time = DateTimeParser.parse!("2022-10-27", "%Y-%m-%d")
    {:ok, expected_datetime, 0} = DateTime.from_iso8601("2022-10-27T00:00:00Z")

    assert parsed_time == expected_datetime
  end

  test "non-compatible regex when parsing" do
    assert_raise Regex.CompileError, fn ->
      DateTimeParser.parse!("2022-10-27 14:47:56", "%Y-%Y-%Y")
    end
  end

  test "invalid datetime format" do
    assert_raise RuntimeError, fn ->
      DateTimeParser.parse!("2022-102-2752 1423:4127:56", "%Y-%m-%d %H:%M:%S")
    end
  end

  test "valid timezone offset (with tz)" do
    parsed_date =
      DateTimeParser.parse!("2022-10-27T00:00:00Z+0230", "%Y-%m-%dT%H:%M:%SZ%z")

    {:ok, expected_datetime, 9000} =
      DateTime.from_iso8601("2022-10-27T00:00:00+02:30")

    assert parsed_date == expected_datetime
  end

  test "valid timezone offset (with UTC)" do
    parsed_date =
      DateTimeParser.parse!(
        "2022-10-27T00:00:00ZUTC+0230",
        "%Y-%m-%dT%H:%M:%SZ%Z"
      )

    assert parsed_date == ~U[2022-10-27 00:00:00Z]
  end

  test "invalid timezone name" do
    assert_raise RuntimeError, fn ->
      DateTimeParser.parse!(
        "2022-10-27T00:00:00ZEtc+0230",
        "%Y-%m-%dT%H:%M:%SZ%Z"
      )
    end
  end

  test "valid datetime with PM/AM" do
    date_under = DateTimeParser.parse!("2022-10-27 06:02pm", "%Y-%m-%d %H:%M%P")
    date_sup = DateTimeParser.parse!("2022-10-27 06:02PM", "%Y-%m-%d %H:%M%p")

    assert date_under == date_sup
  end

  test "valid datetime with PM/AM with two digits" do
    parsed_datetime =
      DateTimeParser.parse!("2022-10-27 06:02pm", "%Y-%m-%d %I:%M%P")

    assert parsed_datetime == ~U[2022-10-27 18:02:00Z]
  end

  test "valid datetime with two-digit year" do
    parsed_date = DateTimeParser.parse!("10-10-27", "%y-%m-%d")

    assert parsed_date == ~U[2010-10-27 00:00:00Z]
  end
end
