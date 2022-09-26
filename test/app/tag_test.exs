defmodule App.TagTest do
  use App.DataCase
  alias App.Tag

  describe "Test contraints and requirements for Tag schema" do
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

  describe "Save tags in Postgres" do
    @valid_attrs %{text: "tag1", person_id: 1}
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
  end
end
