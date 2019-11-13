defmodule App.Ctx.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :text, :string
    field :person_id, :id
    field :status, :id
    many_to_many :tags, App.Ctx.Tag, join_through: "item_tags"
    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
