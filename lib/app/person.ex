defmodule App.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :auth_provider, :string
    field :givenName, :binary
    field :key_id, :integer
    field :locale, :string
    field :picture, :binary
    field :status_id, :id

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:givenName, :auth_provider, :key_id, :picture, :locale])
    |> validate_required([:givenName, :auth_provider, :key_id, :picture, :locale])
  end
end
