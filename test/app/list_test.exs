defmodule App.ListTest do
  use App.DataCase, async: true
  alias App.{Item}

  describe "list" do
    @person_id 7
    # @valid_item_attrs %{text: "some text", person_id: @person_id, status: 2}
    @valid_attrs %{name: "My List", person_id: @person_id, status: 2}
    @valid_item %{text: "Buy Bananas", person_id: 1, status: 2}
    @valid_item2 %{text: "Make Muffins", person_id: 1, status: 2}
    @update_attrs %{name: "some updated text", person_id: @person_id}
    @invalid_attrs %{name: nil}


    test "get_list!/2 returns the list with given id" do
      {:ok, %{model: list}} = App.List.create_list(@valid_attrs)
      assert App.List.get_list!(list.id).name == list.name
    end

    test "get_list_by_cid!/2 returns the list with given cid" do
      {:ok, %{model: list}} = App.List.create_list(@valid_attrs)
      assert App.List.get_list_by_cid!(list.cid).name == list.name
    end

    test "create_list/1 with valid data creates a list" do
      assert {:ok, %{model: list}} =
               App.List.create_list(@valid_attrs)

      assert list.name == @valid_attrs.name
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = App.List.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      {:ok, %{model: list}} = App.List.create_list(@valid_attrs)

      assert {:ok, %{model: list}} =
               App.List.update_list(list, @update_attrs)

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
  end

  test "update_list_seq/3 updates the list.seq for the given list" do
    person_id = 314
    all_list = App.List.get_all_list_for_person(person_id)

    # Create a couple of items:
    assert {:ok, %{model: item1}} =
        Item.create_item(%{text: "buy land!", person_id: person_id, status: 2})
    assert {:ok, %{model: item2}} =
      Item.create_item(%{text: "plant trees & food", person_id: person_id, status: 2})
    assert {:ok, %{model: item3}} =
        Item.create_item(%{text: "live best life", person_id: person_id, status: 2})

    # Add the item cids to the list.seq:
    seq = "#{item1.cid},#{item2.cid},#{item3.cid}"

    # Update the list.seq for the all_list:
    {:ok, %{model: list}} = App.List.update_list_seq(all_list.cid, person_id, seq)
    assert list.seq == seq

    # Reorder the cids and update the list.seq
    updated_seq = "#{item3.cid},#{item2.cid},#{item1.cid}"
    {:ok, %{model: list}} = App.List.update_list_seq(all_list.cid, person_id, updated_seq)
    assert list.seq == updated_seq
  end

  test "remove_item_from_list/3 removes the item.cid from the list.seq" do
    # Random Person ID
    person_id = 386
    all_list = App.List.get_all_list_for_person(person_id)

    # Create items:
    assert {:ok, %{model: item1}} =
      Item.create_item(%{text: "buy land!", person_id: person_id, status: 2})
    assert {:ok, %{model: item2}} =
      Item.create_item(%{text: "prepare for societal collapse", person_id: person_id, status: 2})

    # Add both items to the list:
    seq = "#{item1.cid},#{item2.cid}"
    {:ok, %{model: list}} = App.List.update_list_seq(all_list.cid, person_id, seq)
    assert list.seq == seq

    # Remove the first item from the list:
    {:ok, %{model: list}} = App.List.remove_item_from_list(item1.cid, all_list.cid, person_id)

    # Only item2 should be on the list.seq:
    updated_seq = "#{item2.cid}"
    # Confirm removed:
    assert list.seq == updated_seq
  end


  test "Item.items_with_timers/1 returns a list filtered by list_cid" do
    person_id = 472
    {:ok, %{model: item1}} = Item.create_item(%{@valid_item | person_id: person_id})
    {:ok, %{model: item2}} = Item.create_item(%{@valid_item2 | person_id: person_id})

    # Create a New List:
    lista_attrs = %{name: "Todo List", person_id: person_id, status: 2}
    assert {:ok, %{model: lista}} = App.List.create_list(lista_attrs)
    assert lista.name == lista_attrs.name

    listb_attrs = %{name: "Delegated", person_id: person_id, status: 2}
    assert {:ok, %{model: listb}} = App.List.create_list(listb_attrs)
    assert listb.name == listb_attrs.name

    # Add both items to List A:
    App.List.update_list_seq(lista.cid, person_id, "#{item1.cid},#{item2.cid}")

    # Confirm that both items are on List A:
    seq = App.List.get_list_by_cid!(lista.cid) |> App.List.get_list_seq()
    first = List.first(seq)
    last = List.last(seq)
    assert first == item1.cid
    assert last == item2.cid

    # Move item1 from List A to List B:
    App.List.move_item_from_lista_to_listb(item1.cid, lista.cid, listb.cid, person_id)

    seqa = App.List.get_list_by_cid!(lista.cid) |> App.List.get_list_seq()
    assert not Enum.member?(seqa, item1.cid)

    seqb = App.List.get_list_by_cid!(listb.cid) |> App.List.get_list_seq()
    assert Enum.member?(seqb, item1.cid)
  end

end
