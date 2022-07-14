defmodule App.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Repo
  alias __MODULE__

  schema "status" do
    field :text, App.EctoAtom
    field :code, :integer

    has_many :items, App.Item
    has_many :person, App.Person

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:text, :code])
    |> validate_required([:text])
    |> unique_constraint(:text)
  end

  def create(attrs) do
    %Status{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get_by_text!(text), do: Repo.get_by!(__MODULE__, text: text)

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
