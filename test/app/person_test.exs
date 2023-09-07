defmodule App.PersonTest do
  use ExUnit.Case
  alias App.Person

  @doc """
  Test for `get_person_id/1`
  """
  describe "get_person_id/1" do
    test "returns id when person is present in assigns" do
      assigns = %{person: %{id: 1}}
      assert Person.get_person_id(assigns) == 1
    end

    test "returns 0 when person is not present in assigns" do
      assigns = %{}
      assert Person.get_person_id(assigns) == 0
    end

    test "returns 0 when id is not present in person" do
      assigns = %{person: %{}}
      assert Person.get_person_id(assigns) == 0
    end

    test "returns 0 when id is nil in person" do
      assigns = %{person: %{id: nil}}
      assert Person.get_person_id(assigns) == 0
    end
  end
end
