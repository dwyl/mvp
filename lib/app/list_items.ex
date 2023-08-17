defmodule App.ListItems do
  use Ecto.Schema
  import Ecto.Changeset

  schema "list_items" do
    field :list_id, :id
    field :person_id, :integer
    field :seq, :string

    timestamps()
  end

  @doc false
  def changeset(list_items, attrs) do
    list_items
    |> cast(attrs, [:person_id, :seq])
    |> validate_required([:person_id, :seq])
  end
end
