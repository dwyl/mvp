defmodule App.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.{List, GroupList, Person, GroupPerson, Repo}
  alias __MODULE__

  schema "groups" do
    field :name, :string

    many_to_many(:people, Person, join_through: GroupPerson)
    many_to_many(:lists, List, join_through: GroupList)

    timestamps()
  end

  @doc false
  def changeset(group, attrs \\ %{}) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def list_person_groups(_person_id) do
    []
  end

  def create_group(_person_id, attrs) do
    %Group{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
