defmodule App.PersonTest do
  use App.DataCase
  alias App.{Person, Status}

  describe "person/people" do
    # test "get!/1 returns the person with given id" do
    #   person = item_fixture(@valid_attrs)
    #   assert Item.get_item!(item.id) == item
    # end

    test "create/1 with valid data creates a person" do
      status = Status.get_by_text!(:verified)

      person =
        Person.create(
          %{
            givenName: "aLeX",
            auth_provider: "dwyl",
            local: "SoCal"
          },
          status
        )

      assert person.givenName == "aLeX"
      assert person.status.code == 1
    end
  end
end
