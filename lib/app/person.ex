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
      :status_code
    ])
    |> validate_required([:givenName, :auth_provider])
  end

  def create(attrs) do
    %Person{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  # def get_person!(id), do: Repo.get!(__MODULE__, id)
end
