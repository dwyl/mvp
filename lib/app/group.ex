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

  def changeset_with_lists(group, list_ids) do
    lists = Repo.all(from l in List, where: l.id in ^list_ids)

    group
    |> change()
    |> put_assoc(:lists, lists)
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
    |> Repo.preload(lists: from(l in List, order_by: l.name))
  end

  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  def update_group_with_lists(%Group{} = group, list_ids) do
    group
    |> Group.changeset_with_lists(list_ids)
    |> Repo.update()
  end

  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end
end
