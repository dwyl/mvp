defmodule App.Ctx.Timer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timers" do
    field :end, :naive_datetime
    field :start, :naive_datetime
    field :item_id, :id
    field :person_id, :id

    timestamps()
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [:start, :end])
    |> validate_required([:start, :end])
  end
end
