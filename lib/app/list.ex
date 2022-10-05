defmodule App.List do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias App.{Item, Person, Repo}
  alias __MODULE__

  schema "lists" do
    field :name, :string

    belongs_to :people, Person, references: :person_id, foreign_key: :person_id
    many_to_many(:items, Item, join_through: "items_lists")

    timestamps()
  end

  @doc false
  def changeset(list, attrs \\ %{}) do
    list
    |> cast(attrs, [:person_id, :name])
    |> validate_required([:person_id, :name])
    |> unique_constraint([:name, :person_id], name: :lists_name_person_id_index)
  end

  def create_list(attrs) do
    %List{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get_list!(id), do: Repo.get!(List, id)

  def list_person_lists(person_id) do
    List
    |> where(person_id: ^person_id)
    |> order_by(:name)
    |> Repo.all()
  end

  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  def delete_list(%List{} = list) do
    Repo.delete(list)
  end
end
