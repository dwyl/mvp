defmodule App.ListItems do
  use Ecto.Schema
  import Ecto.Changeset

  schema "list_items" do
    field :person_id, :integer
    field :position, :float
    field :item_id, :id
    field :list_id, :id

    timestamps()
  end

  @doc false
  def changeset(list_items, attrs) do
    list_items
    |> cast(attrs, [:person_id, :position])
    |> validate_required([:person_id, :position])
  end
end
