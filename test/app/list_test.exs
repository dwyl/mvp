defmodule App.ListTest do
  use App.DataCase, async: true
  alias App.{List}

  describe "list" do
    @person_id 7
    @valid_item_attrs %{text: "some text", person_id: @person_id, status: 2}
    @valid_attrs %{name: "My List", person_id: @person_id, status: 2}
    @update_attrs %{name: "some updated text", person_id: @person_id}
    @invalid_attrs %{name: nil}


    test "get_list!/2 returns the list with given id" do
      {:ok, %{model: list, version: _version}} = List.create_list(@valid_attrs)
      assert List.get_list!(list.id).name == list.name
    end

    test "create_list/1 with valid data creates a list" do
      assert {:ok, %{model: list, version: _version}} =
               List.create_list(@valid_attrs)

      assert list.name == @valid_attrs.name
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      {:ok, %{model: list, version: _version}} = List.create_list(@valid_attrs)

      assert {:ok, %{model: list, version: _version}} =
               List.update_list(list, @update_attrs)

      assert list.name == "some updated text"
    end

    test "get_lists_for_person/1 returns the lists for the person_id" do
      person_id = 3
      lists_before = App.List.get_lists_for_person(person_id)
      assert length(lists_before) == 0

      # Create a couple of lists
      {:ok, %{model: all_list}} =
        %{name: "all", person_id: person_id, status: 2}
        |> App.List.create_list()

      {:ok, %{model: recipe_list}} =
        %{name: "Recipes", person_id: person_id, status: 2}
        |> App.List.create_list()

      # Retrieve the lists for the person_id:
      lists_after = App.List.get_lists_for_person(person_id)
      assert length(lists_after) == 2
      assert Enum.member?(lists_after, all_list)
      assert Enum.member?(lists_after, recipe_list)
    end

    test "get_list_by_name!/2 returns the list by name for the person_id" do
      person_id = 4
      %{name: "all", person_id: person_id, status: 2}
        |> App.List.create_list()
      list = App.List.get_list_by_name!("all", person_id)
      assert list.name == "all"
    end

    test "get_all_list_for_person retrieves (or creates) the 'all' list for that person_id" do
      # create an item for the person but don't add it to a list:
      assert {:ok, %{model: item}} = App.Item.create_item(@valid_item_attrs)
      dbg(item)

      App.List.get_all_list_for_person(@person_id)
    end

    # test "create_default_lists/1 creates the default lists" do
    #   # Should have no lists:
    #   person_id = 5
    #   lists = App.List.get_lists_for_person(person_id)
    #   assert length(lists) == 0
    #   # Create the default lists for this person_id:
    #   assert List.create_default_lists(person_id) |> length() == 9
    # end
  end
end
