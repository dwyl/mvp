defmodule App.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias App.{Item, ItemTag, Repo, Timer}
  alias __MODULE__

  @derive {Jason.Encoder, only: [:id, :text, :person_id, :color]}
  schema "tags" do
    field :color, :string
    field :person_id, :integer
    field :text, :string

    field :last_used_at, :naive_datetime, virtual: true
    field :items_count, :integer, virtual: true
    field :total_time_logged, :integer, virtual: true

    many_to_many(:items, Item, join_through: ItemTag)
    timestamps()
  end

  @doc false
  def changeset(tag, attrs \\ %{}) do
    tag
    |> cast(attrs, [:person_id, :text, :color])
    |> validate_required([:person_id, :text, :color])
    |> validate_format(:color, ~r/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
    |> unique_constraint([:text, :person_id], name: :tags_text_person_id_index)
  end

  def create_tag(attrs) do
    %Tag{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  #  def parse_and_create_tags(attrs) do
  #    (attrs[:tags] || "")
  #    |> String.split(",")
  #    |> Enum.map(&String.trim/1)
  #    |> Enum.reject(&(&1 == ""))
  #    |> create_tags(attrs[:person_id])
  #  end

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

  def get_tag(id), do: Repo.get(Tag, id)

  def list_person_tags(person_id) do
    Tag
    |> where(person_id: ^person_id)
    |> order_by(:text)
    |> Repo.all()
  end

  def list_person_tags_complete(person_id) do
    Tag
    |> where(person_id: ^person_id)
    |> join(:left, [t], it in ItemTag, on: t.id == it.tag_id)
    |> join(:left, [t, it], i in Item, on: i.id == it.item_id)
    |> join(:left, [t, it, i], tm in Timer, on: tm.item_id == i.id)
    |> group_by([t], t.id)
    |> select([t, it, i, tm], %{
      t
      | last_used_at: max(it.inserted_at),
        items_count: fragment("count(DISTINCT ?)", i.id),
        total_time_logged:
          sum(
            coalesce(
              fragment(
                "EXTRACT(EPOCH FROM (? - ?))",
                tm.stop,
                tm.start
              ),
              0
            )
          )
    })
    |> order_by([t], t.text)
    |> Repo.all()
  end

  def list_person_tags_text(person_id) do
    Tag
    |> where(person_id: ^person_id)
    |> order_by(:text)
    |> select([t], t.text)
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
