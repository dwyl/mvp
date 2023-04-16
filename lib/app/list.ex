defmodule App.List do
  use Ecto.Schema
  import Ecto.Changeset
  alias PaperTrail
  alias __MODULE__

  schema "lists" do
    field :name, :string
    field :person_id, :integer
    field :status, :integer

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :person_id, :status])
    |> validate_required([:name, :person_id, :status])
  end

  @doc """
  `create_list/1` creates an `list`.

  ## Examples

      iex> create_list(%{text: "Personal Todo List"})
      {:ok, %List{}}

      iex> create_list(%{text: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(attrs) do
    %List{}
    |> changeset(attrs)
    |> PaperTrail.insert()
  end

  @doc """
  `update_list/2` updates a list.

  ## Examples

      iex> update_list(list, %{name: "renamed list"})
      {:ok, %List{}}

      iex> update_list(list, %{name: nil})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> PaperTrail.update()
  end
end
