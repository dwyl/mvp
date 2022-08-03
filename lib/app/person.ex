defmodule App.Person do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Repo
  alias __MODULE__

  schema "people" do
    field :auth_provider, :string
    field :givenName, Fields.Encrypted
    field :key_id, :integer
    field :locale, :string
    field :picture, Fields.Encrypted
    field :status_code, :integer
    field :auth_id, :integer

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [
      :givenName,
      :auth_provider,
      :key_id,
      :picture,
      :locale,
      :status_code,
      :auth_id
    ])
    |> validate_required([:givenName, :auth_provider, :auth_id])
    |> unique_constraint([:auth_id])
  end

  def create(attrs) do
    %Person{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def upsert(attrs) do
    %Person{}
    |> changeset(attrs)
    |> Repo.insert!(on_conflict: :nothing)
  end

  def get_person_by_auth_id!(auth_id),
    do: Repo.get_by!(__MODULE__, auth_id: auth_id)
end
