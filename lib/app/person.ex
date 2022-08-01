defmodule App.Person do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
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

  def get_person!(id), do: Repo.get!(__MODULE__, id)

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(set_id(attrs), [
      :givenName,
      :auth_provider,
      :picture,
      :locale,
      :status_code,
      :id
    ])
    |> validate_required([:givenName, :auth_provider])
  end

  # workaround for people_pkey (unique_constraint)
  # see: github.com/dwyl/app-mvp/issues/115
  defp set_id(attrs) do
    if Map.has_key?(attrs, :id) do
      attrs
    else
      # https://til.hashrocket.com/posts/e0754031e3-counting-records-with-ecto
      id = Repo.aggregate(from(p in "people"), :count, :id)
      Map.put(attrs, :id, id)
    end
  end

  def create(attrs) do
    %Person{}
    |> changeset(attrs)
    |> Repo.insert!()
  end


  def upsert(person) do
    cond do
      # if there is no person.id then create person without it:
      not Map.has_key?(person, :id) ->
        create(person)

      Map.has_key?(person, :id) ->

        case Repo.get_by(__MODULE__, id: person.id) do
          # person not found, create them!
          nil ->
            create(person)

          # person exists, update!
          existing_person ->
            existing_person
            |> changeset(AuthPlug.Helpers.strip_struct_metadata(person))
            |> Repo.update!()
        end
    end
  end
end
