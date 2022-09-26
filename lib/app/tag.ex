defmodule App.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.{Item, ItemTag, Repo}
  alias __MODULE__

  schema "tags" do
    field :text, :string
    field :person_id, :integer

    many_to_many(:items, Item, join_through: ItemTag)
    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:person_id, :text])
    |> validate_required([:person_id, :text])
    |> unique_constraint([:text, :person_id], name: :tags_text_person_id_index)
  end

  def create_tag(attrs) do
    %Tag{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get_tag!(id), do: Repo.get!(Tag, id)
end
