defmodule App.GroupPerson do
  use Ecto.Schema
  alias App.{Group, Person}

  @primary_key false
  schema "groups_people" do
    belongs_to(:group, Group)
    belongs_to :people, Person, references: :person_id, foreign_key: :person_id

    timestamps()
  end
end
