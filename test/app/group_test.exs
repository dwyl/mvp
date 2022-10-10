defmodule App.GroupTest do
  use App.DataCase
  alias App.{Group}

  describe "Test constraints and requirements for Group schema" do
    test "valid tag changeset" do
      changeset = Group.changeset(%Group{}, %{name: "group name"})

      assert changeset.valid?
    end

    test "invalid group changeset when name value missing" do
      changeset = Group.changeset(%Group{}, %{name: ""})
      refute changeset.valid?
    end
  end
end
