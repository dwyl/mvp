defmodule App.Ctx.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :email, :binary
    field :email_hash, :binary
    field :familyName, :binary
    field :givenName, :binary
    field :key_id, :integer
    field :password_hash, :binary
    field :username, :binary
    field :username_hash, :binary
    field :status, :id
    field :tag, :id

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:username, :username_hash, :email, :email_hash, :givenName, :familyName, :password_hash, :key_id])
    |> validate_required([:username, :username_hash, :email, :email_hash, :givenName, :familyName, :password_hash, :key_id])
  end
end
