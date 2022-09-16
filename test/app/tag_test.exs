defmodule App.TagTest do
  use App.DataCase
  alias App.Tag

  test "valid tag changeset" do
    changeset = Tag.changeset(%Tag{}, %{person_id: 1, text: "tag1"})
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
end
