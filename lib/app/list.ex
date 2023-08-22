defmodule App.List do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias App.{Repo}
  alias PaperTrail
  alias __MODULE__

  schema "lists" do
    field :name, :string
    field :person_id, :integer
    field :sort, :integer
    field :status, :integer

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :person_id, :sort, :status])
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

  @doc """
  `get_list_by_name!/2` gets the `list` record by it's `name` attribute.
  e.g: `get_list_by_name!("shopping", 42)`

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list_by_name!("all", 1)
      %List{}

      iex> get_list_by_name!("¯\_(ツ)_/¯", 0)
      ** (Ecto.NoResultsError)

  """
  def get_list_by_name!(name, person_id) do
    Repo.get_by(List, name: name, person_id: person_id)
  end

  @doc """
  get_all_list_for_person()
  """
  def get_all_list_for_person(person_id) do
    all_list = get_list_by_name!("all", person_id)
    dbg(all_list)

    all_list = if all_list == nil do
      # doesn't exist, create it:
      {:ok, %{model: list}} = create_list(%{name: "all", person_id: person_id, status: 2})

      # add all items to the newly created list:

      # return the list:
      list
    end

    dbg(all_list)
  end


  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Below this point is Lists transition code that will be DELETED! #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


end
