defmodule App.PersonTest do
  use App.DataCase
  alias App.Person

  describe "person/people" do
    # test "get!/1 returns the person with given id" do
    #   person = item_fixture(@valid_attrs)
    #   assert Item.get_item!(item.id) == item
    # end

    test "Person.create/1 with valid data creates a person" do
      person =
        Person.create(%{
          givenName: "aLeX",
          auth_provider: "dwyl",
          local: "SoCal",
          status_code: 1,
          auth_id: 1
        })

      assert person.givenName == "aLeX"
      assert person.status_code == 1
    end
  end
end
