defmodule App.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :person_id, :integer
    field :status, :integer
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:person_id, :status, :text])
    |> validate_required([:person_id, :status, :text])
  end
end
