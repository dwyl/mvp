defmodule App.Group do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias App.{List, GroupList, Person, GroupPerson, Repo}
  alias __MODULE__

  schema "groups" do
    field :name, :string

    many_to_many(:people, Person,
      join_through: GroupPerson,
      on_replace: :delete,
      join_keys: [group_id: :id, person_id: :person_id]
    )

    many_to_many(:lists, List, join_through: GroupList, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(group, attrs \\ %{}) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def create_group(person_id, attrs) do
    person = Person.get_person!(person_id)

    %Group{}
    |> changeset(attrs)
    |> put_assoc(:people, [person])
    |> Repo.insert()
  end

  def get_group!(id) do
    Group
    |> Repo.get!(id)
    |> Repo.preload(people: from(p in Person, order_by: p.name))
  end
end
