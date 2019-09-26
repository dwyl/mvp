defmodule App.Ctx.Kind do
  use Ecto.Schema
  import Ecto.Changeset

  schema "kinds" do
    field :text, :string
    belongs_to :human, App.Ctx.Person

    timestamps()
  end

  @doc false
  def changeset(kind, attrs) do
    kind
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
