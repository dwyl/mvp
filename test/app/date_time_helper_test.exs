defmodule App.DateTimeHelperTest do
  use ExUnit.Case
  alias App.DateTimeHelper
  alias Timex

  describe "format_date/1" do
    test "formats a date correctly" do
      dt = Timex.parse!("2023-08-02T15:30:30+00:00", "{ISO:Extended}")
      assert DateTimeHelper.format_date(dt) == "08/02/2023 15:30:30"
    end
  end

  describe "format_duration/1" do
    test "returns an empty string for nil" do
      assert DateTimeHelper.format_duration(nil) == ""
    end

    test "returns an empty string when other than decimal" do
      assert DateTimeHelper.format_duration(12345) == ""
    end

    test "formats a duration correctly" do
      duration_seconds = Decimal.new(12345)

      assert DateTimeHelper.format_duration(duration_seconds) ==
               "3 hours, 25 minutes, 45 seconds"
    end

    test "formats a zero decimal duration correctly" do
      duration_seconds = Decimal.new(0)

      assert DateTimeHelper.format_duration(duration_seconds) ==
               "0 microseconds"
    end
  end
end
