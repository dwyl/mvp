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

    belongs_to :status, App.Status

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
      :locale
    ])
    |> validate_required([:givenName, :auth_provider])
  end

  def create(attrs, status) do
    %Person{}
    |> Repo.preload(:status)
    |> changeset(attrs)
    |> put_assoc(:status, status)
    |> Repo.insert!()
  end
end
