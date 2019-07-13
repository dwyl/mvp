defmodule App.Ctx.Human do
  use Ecto.Schema
  import Ecto.Changeset

  schema "humans" do
    field :email, :binary
    field :email_hash, :binary
    field :firstname, :binary
    field :key_id, :integer
    field :lastname, :binary
    field :password_hash, :binary
    field :username, :binary
    field :username_hash, :binary
    field :status, :id
    field :kind, :id

    timestamps()
  end

  @doc false
  def changeset(human, attrs) do
    human
    |> cast(attrs, [:username, :username_hash, :email, :email_hash, :firstname, :lastname, :password_hash, :key_id])
    |> validate_required([:username, :username_hash, :email, :email_hash, :firstname, :lastname, :password_hash, :key_id])
  end
end
