defmodule App.PersonTest do
  use App.DataCase
  alias App.Person

  describe "Test constraints and requirements for Person schema" do
    test "valid person changeset" do
      changeset = Person.changeset(%Person{}, %{person_id: 1, name: "person1"})

      assert changeset.valid?
    end

    test "invalid person changeset when name value missing" do
      changeset = Person.changeset(%Person{}, %{person_id: 1, name: ""})
      refute changeset.valid?
    end

    test "invalid person changeset when person_id value missing" do
      changeset = Person.changeset(%Person{}, %{name: "person1"})
      refute changeset.valid?
    end
  end

  describe "Save person in Postgres" do
    @valid_attrs %{person_id: 1, name: "person 1"}
    @invalid_attrs %{name: nil}

    test "get_person!/1 returns the person with given id" do
      {:ok, person} = Person.create_person(@valid_attrs)
      assert Person.get_person!(person.person_id).name == person.name
    end

    test "create_person/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Person.create_person(@invalid_attrs)
    end

    test "create_person/1 returns invalid changeset when trying to insert a duplicate name" do
      assert {:ok, _person} = Person.create_person(@valid_attrs)

      assert {:error, _changeset} =
               Person.create_person(%{person_id: 2, name: "person 1"})
    end

    test "get_or_insert preson" do
      assert person = Person.get_or_insert(0)
      assert person.person_id == 0

      {:ok, person} = Person.create_person(@valid_attrs)
      assert get_person = Person.get_or_insert(1)
      assert get_person.name == person.name
    end
  end

  describe "Update person in Postgres" do
    @valid_attrs %{person_id: 1, name: "person 1"}
    @valid_update_attrs %{person_id: 1, name: "person 1 updated"}

    test "create_person/1 returns invalid changeset when trying to insert a duplicate name" do
      assert {:ok, person} = Person.create_person(@valid_attrs)

      assert {:ok, person_updated} =
               Person.update_person(person, @valid_update_attrs)

      assert person_updated.name == "person 1 updated"
    end
  end
end
