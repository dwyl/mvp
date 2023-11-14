defmodule AppWeb.TagsLiveTest do
  use AppWeb.ConnCase, async: true
  alias App.{Item, Timer, Tag}
  import Phoenix.LiveViewTest

  @person_id 55

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/tags")
    assert disconnected_html =~ "Tags"
    assert render(page_live) =~ "Tags"
  end

  # test "display tags on table", %{conn: conn} do
  #   tag1 = add_tag(%{person_id: @person_id, text: "Tag1", color: "#000000"})
  #   add_tag(%{person_id: @person_id, text: "Tag2", color: "#000000"})
  #   add_tag(%{person_id: @person_id, text: "Tag3", color: "#000000"})

  #   {:ok, page_live, _html} = live(conn, "/tags")

  #   assert render(page_live) =~ "Tags"

  #   assert page_live
  #          |> element("td[data-test-id=text_#{tag1.id}")
  #          |> render() =~
  #            "Tag1"
  # end

  defp add_tag(attrs) do
    {:ok, tag} = Tag.create_tag(attrs)

    {:ok, %{model: item}} = Item.create_item(%{
      person_id: @person_id,
      status: 0,
      text: "some item",
      tags: [tag]
    })

    seconds_ago_date = NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -10))
    Timer.start(%{item_id: item.id, person_id: @person_id, start: seconds_ago_date})
    Timer.stop_timer_for_item_id(item.id)

    tag
  end
end
