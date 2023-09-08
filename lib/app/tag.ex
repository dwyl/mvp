defmodule App.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias App.{Item, ItemTag, Repo}
  alias __MODULE__

  schema "tags" do
    field :text, :string
    field :color, :string
    field :person_id, :integer

    many_to_many(:items, Item, join_through: ItemTag)
    timestamps()
  end

  @doc false
  def changeset(tag, attrs \\ %{}) do
    tag
    |> cast(attrs, [:person_id, :text, :color])
    |> validate_required([:person_id, :text, :color])
    |> unique_constraint([:text, :person_id], name: :tags_text_person_id_index)
  end

  def create_tag(attrs) do
    %Tag{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def parse_and_create_tags(attrs) do
    (attrs[:tags] || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> create_tags(attrs[:person_id])
  end

  @doc """
  Insert the list of tag names given as argument.
  The function takes the list of tag names (string) and the person's id
  and returns the list of created tags.
  """
  @spec create_tags(tag_name :: list(String.t()), person_id: integer) :: map()
  def create_tags([], _person_id), do: []

  def create_tags(tag_names, person_id) do
    timestamp =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    placeholders = %{timestamp: timestamp}

    maps =
      Enum.map(
        tag_names,
        &%{
          text: &1,
          person_id: person_id,
          color: App.Color.random(),
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      )

    Repo.insert_all(
      Tag,
      maps,
      placeholders: placeholders,
      on_conflict: :nothing
    )

    Repo.all(
      from t in Tag, where: t.text in ^tag_names and t.person_id == ^person_id
    )
  end

  def get_tag!(id), do: Repo.get!(Tag, id)

  def list_person_tags(person_id) do
    Tag
    |> where(person_id: ^person_id)
    |> order_by(:text)
    |> Repo.all()
  end

  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end
end
