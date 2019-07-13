defmodule App.Ctx.Status do
  use Ecto.Schema
  import Ecto.Changeset

  schema "status" do
    field :text, :string
    belongs_to :human, App.Ctx.Human

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
