defmodule App.ListTest do
  use App.DataCase, async: true
  alias App.{Item, List}

  describe "list" do
    @person_id 7
    # @valid_item_attrs %{text: "some text", person_id: @person_id, status: 2}
    @valid_attrs %{name: "My List", person_id: @person_id, status: 2}
    @update_attrs %{name: "some updated text", person_id: @person_id}
    @invalid_attrs %{name: nil}


    test "get_list!/2 returns the list with given id" do
      {:ok, %{model: list}} = List.create_list(@valid_attrs)
      assert List.get_list!(list.id).name == list.name
    end

    test "get_list_by_cid!/2 returns the list with given cid" do
      {:ok, %{model: list}} = List.create_list(@valid_attrs)
      assert List.get_list_by_cid!(list.cid).name == list.name
    end

    test "create_list/1 with valid data creates a list" do
      assert {:ok, %{model: list}} =
               List.create_list(@valid_attrs)

      assert list.name == @valid_attrs.name
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      {:ok, %{model: list}} = List.create_list(@valid_attrs)

      assert {:ok, %{model: list}} =
               List.update_list(list, @update_attrs)

      assert list.name == "some updated text"
    end

    test "get_lists_for_person/1 returns the lists for the person_id" do
      person_id = 3
      lists_before = App.List.get_lists_for_person(person_id)
      assert lists_before == []

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

    test "get_all_list_for_person retrieves (or creates) the 'all' list for person_id" do
      all_list = App.List.get_all_list_for_person(@person_id)
      assert all_list.name == "all"
    end

    test "add_all_items_to_all_list_for_person_id/1 adds all items to all list for person_id" do
      person_id = 42
      # create an item for the person but do NOT add it to any list:
      assert {:ok, %{model: item1}} =
          Item.create_item(%{text: "buy land!", person_id: person_id, status: 2})
      assert {:ok, %{model: item2}} =
        Item.create_item(%{text: "plant trees & food", person_id: person_id, status: 2})
      assert {:ok, %{model: item3}} =
          Item.create_item(%{text: "live best life", person_id: person_id, status: 2})

      # Invoke the biz logic:
      App.List.add_all_items_to_all_list_for_person_id(person_id)

      # Confirm that the item.id is in the squence of item ids for the "all" list:
      all_list = App.List.get_all_list_for_person(person_id)
      all_items_seq = all_list.seq |> String.split(",")

      assert Enum.member?(all_items_seq, "#{item1.cid}")
      assert Enum.member?(all_items_seq, "#{item2.cid}")
      assert Enum.member?(all_items_seq, "#{item3.cid}")
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
