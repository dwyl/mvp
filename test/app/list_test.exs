defmodule App.ListTest do
  use App.DataCase, async: false
  alias App.{Person, List}

  setup [:create_person]

  describe "Test constraints and requirements for List schema" do
    test "valid list changeset" do
      changeset = List.changeset(%List{}, %{person_id: 1, name: "list 1"})

      assert changeset.valid?
    end

    test "invalid list changeset when person_id value missing" do
      changeset = List.changeset(%List{}, %{name: "list 1"})
      refute changeset.valid?
    end

    test "invalid list changeset when name value missing" do
      changeset = List.changeset(%List{}, %{person_id: 1})
      refute changeset.valid?
    end
  end

  describe "Save list in Postgres" do
    @valid_attrs %{person_id: 1, name: "list 1"}
    @invalid_attrs %{name: nil}

    test "get_list!/1 returns the list with given id" do
      {:ok, list} = List.create_list(@valid_attrs)
      assert List.get_list!(list.id).name == list.name
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = List.create_list(@invalid_attrs)
    end

    test "create_list/1 returns invalid changeset when trying to insert a duplicate name" do
      assert {:ok, _list} = List.create_list(@valid_attrs)

      assert {:error, _changeset} = List.create_list(@valid_attrs)
    end

    test "get lists from ids" do
      {:ok, list} = List.create_list(@valid_attrs)
      assert lists = List.get_lists_from_ids([list.id])
      assert length(lists) == 1
    end

    test "get the lists for a person" do
      {:ok, _list} = List.create_list(@valid_attrs)
      assert lists = List.list_person_lists(1)
      assert length(lists) == 1
    end
  end

  describe "Update list in Postgres" do
    @valid_attrs %{person_id: 1, name: "list 1"}
    @valid_update_attrs %{person_id: 1, name: "list 1 updated"}

    test "update_list/2 update the list name" do
      assert {:ok, list} = List.create_list(@valid_attrs)

      assert {:ok, list_updated} = List.update_list(list, @valid_update_attrs)

      assert list_updated.name == "list 1 updated"
    end
  end

  describe "Delete list in Postgres" do
    @valid_attrs %{person_id: 1, name: "list 1"}

    test "delet the list" do
      assert {:ok, list} = List.create_list(@valid_attrs)
      assert {:ok, _} = List.delete_list(list)
    end
  end

  defp create_person(_) do
    person = Person.create_person(%{"person_id" => 1, "name" => "guest"})
    %{person: person}
  end
end
