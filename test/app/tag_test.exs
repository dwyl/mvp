defmodule App.TagTest do
  use App.DataCase
  alias App.Tag

  describe "Test constraints and requirements for Tag schema" do
    test "valid tag changeset" do
      changeset =
        Tag.changeset(%Tag{}, %{person_id: 1, text: "tag1", color: "red-300"})

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
    @valid_attrs %{text: "tag1", person_id: 1, color: "red-300"}
    @invalid_attrs %{text: nil}

    test "get_tag!/1 returns the tag with given id" do
      {:ok, tag} = Tag.create_tag(@valid_attrs)
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
  end
end
