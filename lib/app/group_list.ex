defmodule App.GroupList do
  use Ecto.Schema
  alias App.{Group, List}

  @primary_key false
  schema "groups_lists" do
    belongs_to(:group, Group)
    belongs_to(:list, List)

    timestamps()
  end
end
