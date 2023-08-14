defmodule App.ListTest do
  use App.DataCase, async: true
  alias App.{List}

  describe "list" do
    @valid_attrs %{text: "My List", person_id: 1, status: 2}
    @update_attrs %{text: "some updated text", person_id: 1}
    @invalid_attrs %{text: nil}

    test "get_list!/2 returns the list with given id" do
      {:ok, %{model: list, version: _version}} = List.create_list(@valid_attrs)
      assert List.get_list!(list.id).text == list.text
    end

    test "create_list/1 with valid data creates a list" do
      assert {:ok, %{model: list, version: _version}} =
               List.create_list(@valid_attrs)

      assert list.text == @valid_attrs.text
      l = List.get_person_lists(list.person_id) |> Enum.at(0)
      assert l.text == @valid_attrs.text
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      {:ok, %{model: list, version: _version}} = List.create_list(@valid_attrs)

      assert {:ok, %{model: list, version: _version}} =
               List.update_list(list, @update_attrs)

      assert list.text == "some updated text"
    end

    test "get_person_lists/1 returns the lists for the person_id" do
      person_id = 3
      lists_before = App.List.get_person_lists(person_id)
      assert length(lists_before) == 0

      # Create a couple of lists
      {:ok, %{model: all_list}} =
        %{text: "all", person_id: person_id, status: 2}
        |> App.List.create_list()

      {:ok, %{model: recipe_list}} =
        %{text: "Recipes", person_id: person_id, status: 2}
        |> App.List.create_list()

      # Retrieve the lists for the person_id:
      lists_after = App.List.get_person_lists(person_id)
      assert length(lists_after) == 2
      assert Enum.member?(lists_after, all_list)
      assert Enum.member?(lists_after, recipe_list)
    end

    test "get_list_by_text!/2 returns the list for the person_id by text" do
      person_id = 4

      {:ok, %{model: all_list}} =
        %{text: "all", person_id: person_id, status: 2}
        |> App.List.create_list()

      list = App.List.get_list_by_text!(person_id, "all")
      assert list.text == "all"
      assert list.id == all_list.id
    end

    test "create_default_lists/1 creates the default lists" do
      # Should have no lists:
      person_id = 5
      lists = App.List.get_person_lists(person_id)
      assert length(lists) == 0
      # Create the default lists for this person_id:
      assert List.create_default_lists(person_id) |> length() == 9
    end
  end
end
