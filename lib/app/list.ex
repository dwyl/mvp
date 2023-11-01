defmodule App.List do
  require Logger
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias App.{Repo}
  alias PaperTrail
  alias __MODULE__

  schema "lists" do
    field :cid, :string
    field :name, :string
    field :person_id, :integer
    field :seq, :string
    field :sort, :integer
    field :status, :integer

    timestamps()
  end

  @doc false
  def changeset(list, attrs \\ %{}) do
    list
    |> cast(attrs, [:name, :person_id, :seq, :sort, :status])
    |> validate_required([:name, :person_id])
    |> App.Cid.put_cid()
  end

  # Update an list without changing the cid ref: #418
  def changeset_update(list, attrs \\ %{}) do
    list
    |> cast(attrs, [:name, :person_id, :seq, :sort, :status])
    |> validate_required([:cid, :name, :person_id])
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
  `delete_list/1` "soft" deletes a list
  so it can easily be restored in the event of mistaken deletion.
  """
  def delete_list(id) do
    get_list!(id)
    |> changeset_update(%{status: 6})
    |> Repo.update()
  end

  @doc """
  `get_list_by_cid!/1` gets the `list` record by its' `cid`.

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!("cidhere")
      %List{}

      iex> get_list!(420)
      ** (Ecto.NoResultsError)

  """
  def get_list_by_cid!(cid) do
    List
    |> where(cid: ^cid)
    |> Repo.one!()
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
    |> List.changeset_update(attrs)
    |> PaperTrail.update()
  end

  @doc """
  `get_lists_for_person/1` gets all lists for a person by `person_id`.
  """
  def get_lists_for_person(person_id) do
    List
    |> where(person_id: ^person_id)
    |> where([l], l.status != 6)
    |> order_by(asc: :name)
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
  get_all_list_for_person/1 gets or creates the "all" list for a given `person_id`
  """
  def get_all_list_for_person(person_id) do
    # IO.inspect("get_all_list_for_person(person_id: #{person_id})")
    all_list = get_list_by_name!("all", person_id)

    if all_list == nil do
      # doesn't exist, create it:
      {:ok, %{model: list}} =
        create_list(%{name: "all", person_id: person_id, status: 2})

      list
    else
      all_list
    end
  end

  @doc """
  `update_list_seq/3` update the `list.seq` for the `list.cid` for the `person_id`.
  """
  def update_list_seq(list_cid, person_id, seq) do
    list = get_list_by_cid!(list_cid)
    update_list(list, %{seq: seq, person_id: person_id})
  end

  @doc """
  `add_item_to_list/3` adds the `item.cid` to the `list.cid` for the given `person_id`.
  """
  def add_item_to_list(item_cid, list_cid, person_id) do
    list = get_list_by_cid!(list_cid) |> dbg()
    prev_seq = get_list_seq(list) |> dbg()
    seq = [item_cid | prev_seq] |> Enum.join(",")
    update_list(list, %{seq: seq, person_id: person_id})
  end

  @doc """
  `remove_item_from_list/3` update the `list.seq` for the `list.cid` for the `person_id`.
  """
  def remove_item_from_list(item_cid, list_cid, person_id) do
    list = get_list_by_cid!(list_cid)
    # get existing list.seq
    seq =
      get_list_seq(list)
      # remove the item_cid from the list.seq:
      |> Useful.remove_item_from_list(item_cid)
      |> Enum.join(",")

    update_list(list, %{seq: seq, person_id: person_id})
  end

  @doc """
  `move_item_from_lista_to_listb/4` moves the `item_cid`
  from `lista_cid` to `listb_cid` (removes from `lista`) for `person_id`.
  "From A to B".
  """
  def move_item_from_lista_to_listb(item_cid, lista_cid, listb_cid, person_id) do
    # Remove from List A:
    remove_item_from_list(item_cid, lista_cid, person_id)
    # Add to List B:
    add_item_to_list(item_cid, listb_cid, person_id)
  end

  # feel free to refactor this to use pattern matching:
  def add_papertrail_item_to_all_list(tuple) do
    # extract the item from the tuple:
    try do
      {:ok, %{model: item}} = tuple
      all_list = App.List.get_all_list_for_person(item.person_id)
      add_item_to_list(item.cid, all_list.cid, item.person_id)
    rescue
      e ->
        Logger.error(Exception.format(:error, e, __STACKTRACE__))
    end

    # return the original tuple as expected downstream:
    tuple
  end

  @doc """
  `get_list_seq/1` receives a `%List{}` `Map`/`Struct`
  and returns a `List` of `item` `cids`
  that can easily be used to lookup which `items` are on a given `list`.
  e.g: ["F4VbyA5NNSxNvVwAAAWi", "A8y3Fk4ht", "RJX0VSn", "etc"]
  OR if the `list` does not yet have an `items`, returns an *empty* `List`: []
  """
  def get_list_seq(list) do
    if is_nil(list.seq) do
      []
    else
      list.seq |> String.split(",")
    end
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Below this point is Lists transition code that will be DELETED! #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

  @doc """
  `add_all_items_to_all_list_for_person_id/1` does *exactly* what its' name suggests.
  Adds *all* the person's `items` to the `list_items.seq`.
  """
  def add_all_items_to_all_list_for_person_id(person_id) do
    all_list = App.List.get_all_list_for_person(person_id)
    # dbg(all_list)
    all_items = App.Item.all_items_for_person(person_id)
    # dbg(all_items)
    prev_seq = get_list_seq(all_list)
    # Add add each `item.id` to the sequence of item ids:
    seq =
      Enum.reduce(all_items, prev_seq, fn i, acc ->
        # Avoid adding duplicates
        if Enum.member?(acc, i.cid) do
          acc
        else
          [i.cid | acc]
        end
      end)
      |> Enum.uniq()
      |> Enum.filter(fn cid -> cid != nil && cid != "" end)
      |> Enum.join(",")

    update_list(all_list, %{seq: seq})
  end
end
