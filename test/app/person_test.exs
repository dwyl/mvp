defmodule App.PersonTest do
  use App.DataCase
  alias App.Person

  describe "people" do
    @valid_attrs %{
      status: 1
    }
    @update_attrs %{
      status: 2
    }

    test "create_person/1 with valid data creates a person" do
      person = Person.create_person(@valid_attrs)
      assert person.status == 1
    end

    test "get_person/1 returns the person with given id" do
      person = create_person()
      got_person = Person.get_person(person.id)

      assert got_person.id == person.id
    end

    test "usert_person/1 with valid data creates the person" do
      attrs = Map.merge(@valid_attrs, %{id: :rand.uniform(1_000_000)})
      person = Person.upsert_person(attrs)
      assert person.status == @valid_attrs.status
    end

    test "usert_person/1 with valid update data updates the person" do
      person = create_person()
      update_data = Map.merge(@update_attrs, %{id: person.id})
      updated_person = Person.upsert_person(update_data)

      assert updated_person.status == @update_attrs.status
    end
  end
end
