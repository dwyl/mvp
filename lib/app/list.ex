defmodule App.List do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias App.{Repo}
  alias PaperTrail
  alias __MODULE__

  schema "lists" do
    field :text, :string
    field :person_id, :integer
    field :status, :integer

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:text, :person_id, :status])
    |> validate_required([:text, :person_id])
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
  `get_person_lists/1` gets all lists for a person by `person_id`.
  """
  def get_person_lists(person_id) do
    List
    |> where(person_id: ^person_id)
    |> Repo.all()
  end

  @default_lists ~w(All Meals Recipes Shopping Todo)
  @doc """
  `create_default_lists/1` create the default "All" list
  for the `person_id` if it does not already exist.
  """
  def create_default_lists(person_id) do
    # Check if the "All" list exists for the person_id
    lists = get_person_lists(person_id)
    # Extract just the list.text (name) from the person's lists:
    list_names = Enum.reduce(lists, [], fn l, acc -> [l.text | acc] end)
    # Quick check for length of lists:
    if length(list_names) < length(@default_lists) do
      create_list_if_not_present(list_names, person_id)
      # Re-fetch the list of lists for the person_id
      get_person_lists(person_id)
    else
      # Return the list we got above
      lists
    end
  end

  @doc """
  `create_list_if_not_present/1` create the default "All" list
  for the `person_id` if it does not already exist.
  """
  def create_list_if_not_present(list_names, person_id) do
    Enum.each(@default_lists, fn name ->
      # Create the list if it does not already exists
      unless Enum.member?(list_names, name) do
        %{text: name, person_id: person_id, status: 2}
        |> List.create_list()
      end
    end)
  end

  @doc """
  `get_list_by_text!/2` gets the `list` record by it's `text` attribute.
  e.g: `get_list_by_text!(42, "Shopping")`

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list_by_text!(0, "All")
      %List{}

      iex> get_list_by_text!(0, "¯\_(ツ)_/¯")
      ** (Ecto.NoResultsError)

  """
  def get_list_by_text!(person_id, text) do
    Repo.get_by(List, text: text, person_id: person_id)
  end
end
