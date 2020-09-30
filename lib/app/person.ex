defmodule App.Person do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "people" do
    field :status, :id
    field :tag, :id
    timestamps()
  end

  @doc """
  Default attributes validation for Person
  """
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:id, :status, :tag])
  end

  def create_person(attrs) do
    changeset(%Person{}, attrs)
    |> Repo.insert!()
  end

  def get_person(id) do
    Repo.get_by(__MODULE__, id: id)
  end

  def upsert_person(person) do
    case get_person(person.id) do
      # not found:
      nil ->
        create_person(person)

      # existing person:
      ep ->
        merged = Map.merge(AuthPlug.Helpers.strip_struct_metadata(ep), person)
        {:ok, person} = Repo.update(changeset(%Person{id: ep.id}, merged))

        person
    end
  end
end
