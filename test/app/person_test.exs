defmodule App.PersonTest do
  use App.DataCase
  alias App.Person

  describe "person/people" do
    test "get_person!/1 returns the person with given id" do
      person = Person.upsert(%{givenName: "aLeX", auth_provider: "test"})
      assert Person.get_person!(person.id) == person
    end

    test "Person.create/1 with valid data creates a person" do
      person = Person.create(
          %{
            givenName: "aLeX",
            auth_provider: "dwyl",
            status_code: 1
          }
        )

      assert person.givenName == "aLeX"
      assert person.status_code == 1
    end

    test "Person.upsert/1 with valid data updates a person" do
      # use upsert/1 to *insert* a new person:
      person = Person.upsert(%{
        givenName: "aLeX",
        auth_provider: "dwyl",
        status_code: 1
      })
      assert person.givenName == "aLeX"
      assert person.status_code == 1

      # update the auth_provider for the person record:
      person_updated = Person.upsert(%{person | auth_provider: "updated"})

      assert person.id == person_updated.id
      assert person_updated.auth_provider == "updated"
    end
  end
end
