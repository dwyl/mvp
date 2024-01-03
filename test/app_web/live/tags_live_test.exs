defmodule AppWeb.TagsLiveTest do
  use AppWeb.ConnCase, async: true
  alias App.{Item, Timer, Tag}
  import Phoenix.LiveViewTest

  @person_id 0

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/tags")
    assert disconnected_html =~ "Tags"
    assert render(page_live) =~ "Tags"
  end

  test "display tags on table", %{conn: conn} do
    tag1 = add_test_tag_with_details(%{person_id: @person_id, text: "Tag1", color: "#000000"})
    tag2 = add_test_tag_with_details(%{person_id: @person_id, text: "Tag2", color: "#000000"})
    tag3 = add_test_tag_with_details(%{person_id: @person_id, text: "Tag3", color: "#000000"})

    {:ok, page_live, _html} = live(conn, "/tags")

    assert render(page_live) =~ "Tags"

    assert page_live
           |> element("td[data-test-id=text_#{tag1.id}")
           |> render() =~
             "Tag1"

    assert page_live
           |> element("td[data-test-id=text_#{tag2.id}")
           |> render() =~
             "Tag2"

    assert page_live
           |> element("td[data-test-id=text_#{tag3.id}")
           |> render() =~
             "Tag3"
  end

  @tag tags: true
  test "sorting column when clicked", %{conn: conn} do
    add_test_tag_with_details(%{person_id: @person_id, text: "a", color: "#000000"})
    add_test_tag_with_details(%{person_id: @person_id, text: "z", color: "#000000"})

    {:ok, page_live, _html} = live(conn, "/tags")

    # sort first time
    result =
      page_live |> element("th[phx-value-key=text]") |> render_click()

    [first_element | _] = Floki.find(result, "td[data-test-id^=text_]")
    assert first_element |> Floki.text() =~ "z"

    # sort second time
    result =
      page_live |> element("th[phx-value-key=text]") |> render_click()

    [first_element | _] = Floki.find(result, "td[data-test-id^=text_]")

    assert first_element |> Floki.text() =~ "a"
  end

  defp add_test_tag_with_details(attrs) do
    {:ok, tag} = Tag.create_tag(attrs)

    {:ok, %{model: item}} = Item.create_item(%{
      person_id: tag.person_id,
      status: 0,
      text: "some item",
      tags: [tag]
    })

    seconds_ago_date = NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -10))
    Timer.start(%{item_id: item.id, person_id: tag.person_id, start: seconds_ago_date})
    Timer.stop_timer_for_item_id(item.id)

    tag
  end
end
