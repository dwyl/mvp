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

  def get_person!(id) do
    __MODULE__
    |> Repo.get_by!(id: id)
  end

  def upsert_person(person) do
    case get_person!(person.id) do
      nil ->
        create_person(person)

      # existing person
      ep ->
        merged = Map.merge(AuthPlug.Helpers.strip_struct_metadata(ep), person)
        {:ok, person} = Repo.update(changeset(%Person{id: ep.id}, merged))
        # ensure that the preloads are returned:
        person
    end
  end
end
