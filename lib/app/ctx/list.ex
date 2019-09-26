defmodule App.Ctx.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :title, :string
    field :person_id, :id # the owner of the list
    field :status, :id
    field :kind, :id
    has_many :items, App.Ctx.Item # lists have one or more items

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
