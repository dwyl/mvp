defmodule App.Ctx.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :email, :binary
    field :email_hash, :binary
    field :familyName, :binary
    field :givenName, :binary
    field :password_hash, :binary
    field :username, :binary
    field :username_hash, :binary
    field :status, :id
    field :tag, :id
    field :key_id, :integer

    has_many :sessions, App.Ctx.Session
    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:username, :username_hash, :email, :email_hash, :givenName, :familyName, :password_hash, :key_id])
    |> validate_required([:username, :username_hash, :email, :email_hash, :givenName, :familyName, :password_hash, :key_id])
  end

  def google_changeset(profile, attrs) do
    # person = 
    profile
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end
end
