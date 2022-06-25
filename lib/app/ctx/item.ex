defmodule App.Ctx.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :text, :string
    field :person_id, :id
    field :status, :id

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
