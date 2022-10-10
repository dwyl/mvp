defmodule App.Person do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias App.{Item, Group, GroupPerson, Repo, Tag}
  alias __MODULE__
  # https://hexdocs.pm/phoenix/Phoenix.Param.html
  @derive {Phoenix.Param, key: :person_id}

  @primary_key {:person_id, :id, autogenerate: false}
  schema "people" do
    field :name, :string

    has_many :items, Item, foreign_key: :person_id
    has_many :tags, Tag, foreign_key: :person_id

    many_to_many(:groups, Group,
      join_through: GroupPerson,
      join_keys: [person_id: :person_id, group_id: :id]
    )

    timestamps()
  end

  @doc false
  def changeset(person, attrs \\ %{}) do
    person
    |> cast(attrs, [:person_id, :name])
    |> validate_required([:person_id, :name])
    |> unique_constraint(:name, name: :people_name_index)
  end

  def create_person(attrs) do
    %Person{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get_person!(person_id), do: Repo.get!(Person, person_id)
  def get_person_by_name(name), do: Repo.get_by(Person, name: name)

  def get_person_with_groups!(person_id) do
    Person
    |> Repo.get!(person_id)
    |> Repo.preload(groups: from(g in Group, order_by: g.name))
  end

  def update_person(%Person{} = person, attrs) do
    person
    |> Person.changeset(attrs)
    |> Repo.update()
  end

  def get_or_insert(person_id) do
    Repo.get_by(Person, person_id: person_id) ||
      Repo.insert!(%Person{person_id: person_id})
  end
end
