defmodule App.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.{Item, ItemTag}

  schema "tags" do
    field :text, :string

    many_to_many(:items, Item, join_through: ItemTag)
    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end