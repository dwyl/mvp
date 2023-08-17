defmodule App.List do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias App.{Repo}
  alias PaperTrail
  alias __MODULE__

  schema "lists" do
    field :name, :string
    field :status, :integer
    field :person_id, :integer

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :person_id, :status])
    |> validate_required([:name, :person_id])
  end

  @doc """
  `create_list/1` creates an `list`.

  ## Examples

      iex> create_list(%{name: "Personal Todo List"})
      {:ok, %List{}}

      iex> create_list(%{name: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(attrs) do
    %List{}
    |> changeset(attrs)
    |> PaperTrail.insert()
  end

  @doc """
  `get_list!/1` gets the `list` record.

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!(17)
      %List{}

      iex> get_list!(420)
      ** (Ecto.NoResultsError)

  """
  def get_list!(id) do
    List
    |> Repo.get!(id)
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

  @doc """
  `get_lists_for_person/1` gets all lists for a person by `person_id`.
  """
  def get_lists_for_person(person_id) do
    List
    |> where(person_id: ^person_id)
    |> Repo.all()
  end


end
