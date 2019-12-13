defmodule AppWeb.CaptureView do
  use AppWeb, :view

  def render("capture.json", data) do
    data.item
  end

  def render("capture_error.json", data) do
    data.err
  end
end
