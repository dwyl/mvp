defmodule App.Ctx.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :text, :string
    field :person_id, :id # item always belongs to a person
    field :status, :id
    field :kind, :id
    belongs_to :list, App.Ctx.List # an item can be linked to a list

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
