defmodule App.TagTest do
  use App.DataCase, async: true
  alias App.{Item, Tag, Timer}

  describe "Test constraints and requirements for Tag schema" do
    test "valid tag changeset" do
      changeset =
        Tag.changeset(%Tag{}, %{person_id: 1, text: "tag1", color: "#FCA5A5"})

      assert changeset.valid?
    end

    test "invalid tag changeset when person_id value missing" do
      changeset = Tag.changeset(%Tag{}, %{text: "tag1"})
      refute changeset.valid?
    end

    test "invalid tag changeset when text value missing" do
      changeset = Tag.changeset(%Tag{}, %{person_id: 1})
      refute changeset.valid?
    end

    test "invalid tag changeset when color value missing" do
      changeset = Tag.changeset(%Tag{}, %{person_id: 1, text: "tag1"})
      refute changeset.valid?
    end
  end

  describe "Save tags in Postgres" do
    @valid_attrs %{text: "tag1", person_id: 1, color: "#FCA5A5"}
    @invalid_attrs %{text: nil}

    test "get_tag!/1 returns the tag with given id" do
      tag = add_test_tag(@valid_attrs)
      assert Tag.get_tag!(tag.id).text == tag.text
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tag.create_tag(@invalid_attrs)
    end

    test "create_tag/1 returns invalid changeset when trying to insert a duplicate tag" do
      assert {:ok, _tag} = Tag.create_tag(@valid_attrs)
      assert {:error, _changeset} = Tag.create_tag(@valid_attrs)
    end

    test "insert list of tag names" do
      assert tags = Tag.create_tags(["tag1", "tag2", "tag3"], 1)
      assert length(tags) == 3
    end

    test "returns empty list when attempting to insert empty list of tags" do
      assert tags = Tag.create_tags([], 1)
      assert length(tags) == 0
    end

    test "delete tag" do
      tag = add_test_tag(@valid_attrs)
      assert {:ok, _etc} = Tag.delete_tag(tag)
    end
  end

  describe "List tags" do
    @valid_attrs %{text: "tag1", person_id: 1, color: "#FCA5A5"}

    test "list_person_tags_text/0 returns the tags texts" do
      add_test_tag(@valid_attrs)
      tags_text_array = Tag.list_person_tags_text(@valid_attrs.person_id)
      assert length(tags_text_array) == 1
      assert Enum.at(tags_text_array, 0) == @valid_attrs.text
    end
  end

  describe "list_person_tags/1" do
    test "returns an empty list for a person with no tags" do
      assert [] == Tag.list_person_tags(-1)
    end

    test "returns a single tag for a person with one tag" do
      tag = add_test_tag(%{text: "TestTag", person_id: 1, color: "#FCA5A5"})
      assert [tag] == Tag.list_person_tags(1)
    end

    test "returns tags in alphabetical order for a person with multiple tags" do
      add_test_tag(%{text: "BTag", person_id: 2, color: "#FCA5A5"})
      add_test_tag(%{text: "ATag", person_id: 2, color: "#FCA5A5"})

      tags = Tag.list_person_tags(2)
      assert length(tags) == 2
      assert tags |> Enum.map(& &1.text) == ["ATag", "BTag"]
    end
  end

  describe "list_person_tags_complete/3" do
    test "returns detailed tag information for a given person" do
      add_test_tag_with_details(%{person_id: 3, text: "DetailedTag", color: "#FCA5A5"})

      tags = Tag.list_person_tags_complete(3)
      assert length(tags) > 0
      assert tags |> Enum.all?(&is_map(&1))
      assert tags |> Enum.all?(&Map.has_key?(&1, :last_used_at))
      assert tags |> Enum.all?(&Map.has_key?(&1, :items_count))
      assert tags |> Enum.all?(&Map.has_key?(&1, :total_time_logged))
    end

    test "sorts tags based on specified sort_column and sort_order" do
      add_test_tag_with_details(%{person_id: 4, text: "CTag", color: "#FCA5A5"})
      add_test_tag_with_details(%{person_id: 4, text: "ATag", color: "#FCA5A5"})
      add_test_tag_with_details(%{person_id: 4, text: "BTag", color: "#FCA5A5"})

      tags = Tag.list_person_tags_complete(4, :text, :asc)
      assert tags |> Enum.map(& &1.text) == ["ATag", "BTag", "CTag"]
    end

    test "sorts tags with desc sort_order" do
      add_test_tag_with_details(%{person_id: 4, text: "CTag", color: "#FCA5A5"})
      add_test_tag_with_details(%{person_id: 4, text: "ATag", color: "#FCA5A5"})
      add_test_tag_with_details(%{person_id: 4, text: "BTag", color: "#FCA5A5"})

      tags = Tag.list_person_tags_complete(4, :text, :desc)
      assert tags |> Enum.map(& &1.text) == ["CTag", "BTag", "ATag"]
    end

    test "uses default sort_order when none are provided" do
      add_test_tag_with_details(%{person_id: 5, text: "SingleTag", color: "#FCA5A5"})

      tags = Tag.list_person_tags_complete(5, :text)
      assert length(tags) == 1
    end

    test "uses default parameters when none are provided" do
      add_test_tag_with_details(%{person_id: 5, text: "SingleTag", color: "#FCA5A5"})

      tags = Tag.list_person_tags_complete(5)
      assert length(tags) == 1
    end

    test "handles invalid column" do
      add_test_tag_with_details(%{person_id: 6, text: "BTag", color: "#FCA5A5"})
      add_test_tag_with_details(%{person_id: 6, text: "AnotherTag", color: "#FCA5A5"})

      tags = Tag.list_person_tags_complete(6, :invalid_column)
      assert length(tags) == 2
      assert tags |> Enum.map(& &1.text) == ["AnotherTag", "BTag"]
    end
  end

  defp add_test_tag(attrs) do
    {:ok, tag} = Tag.create_tag(attrs)
    tag
  end

  defp add_test_tag_with_details(attrs) do
    tag = add_test_tag(attrs)

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
