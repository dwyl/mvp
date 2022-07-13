defmodule App.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Repo
  alias __MODULE__

  schema "status" do
    field :text, App.EctoAtom
    field :status_code, :integer

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:text, :status_code])
    |> validate_required([:text])
  end

  def create(attrs) do
    %Status{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def upsert(attrs) do
    case Repo.get_by(__MODULE__, text: attrs.text) do
      # create status
      nil ->
        create(attrs)

      status ->
        {:ok, status}
    end
  end
end
