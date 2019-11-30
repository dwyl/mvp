defmodule App.Ctx.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :email, Fields.EmailEncrypted
    field :email_hash, Fields.EmailHash
    field :familyName, :binary
    field :givenName, :binary
    field :locale, :string
    field :password_hash, :binary
    field :picture, :binary
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
    |> cast(attrs, [:username, :username_hash, :email, :givenName, :familyName, :password_hash, :key_id, :locale, :picture])
    |> Map.put(:email_hash, Fields.EmailHash.dump(person["email"]))
    |> IO.inspect(label: "person")
    |> validate_required([:username, :username_hash, :email, :email_hash, :givenName, :familyName, :password_hash, :key_id])
  end

  def google_changeset(profile, attrs) do
    profile
    |> cast(attrs, [:email, :givenName, :familyName, :picture, :locale])
    |> validate_required([:email])
  end
end
