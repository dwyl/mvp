defmodule App.Item do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias PaperTrail
  alias App.{Repo, Tag, ItemTag, Timer}
  alias __MODULE__
  require Logger

  @derive {Jason.Encoder,
           except: [:__meta__, :__struct__, :timer, :inserted_at, :updated_at]}
  schema "items" do
    field :person_id, :integer
    field :status, :integer
    field :text, :string
    field :position, :integer

    has_many :timer, Timer
    many_to_many(:tags, Tag, join_through: ItemTag, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:person_id, :status, :text, :position])
    |> validate_required([:text, :person_id])
  end

  def changeset_with_tags(item, attrs) do
    changeset(item, attrs)
    |> put_assoc(:tags, attrs.tags)
  end

  def draft_changeset(item, attrs) do
    item
    |> cast(attrs, [:person_id, :status, :text, :position])
    |> validate_required([:person_id])
  end

  @doc """
  `create_item/1` creates an `item`.

  ## Examples

      iex> create_item(%{text: "Learn LiveView"})
      {:ok, %Item{}}

      iex> create_item(%{text: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs) do
    ## Make room at beginning of list first.
    reorder_list_to_add_item(%Item{position: -1})

    %Item{position: 0}
    |> changeset(attrs)
    |> PaperTrail.insert(originator: %{id: Map.get(attrs, :person_id, 0)})
  end

  @doc """
  Creates an `item` with tags.

  ## Examples

      iex> create_item_with_tags(%{text: "Learn LiveView", tags: [tag1, tag2]})
      {:ok, %Item{}}

      iex> create_item_with_tags(%{text: nil})
      {:error, %Ecto.Changeset{}}
  """
  def create_item_with_tags(attrs) do
    # Make room at beginning of list first.
    # This increments the positions of the items.
    reorder_list_to_add_item(%Item{position: -1})

    %Item{position: 0}
    |> changeset_with_tags(attrs)
    |> PaperTrail.insert(originator: %{id: Map.get(attrs, :person_id, 0)})
  end

  @doc """
  `get_item!/1` gets a single Item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id) do
    Item
    |> Repo.get!(id)
    |> Repo.preload(tags: from(t in Tag, order_by: t.text))
  end

  def get_draft_item(person_id) do
    Repo.get_by(Item, status: 7, person_id: person_id) ||
      Repo.insert!(%Item{person_id: person_id, status: 7})
  end

  @doc """
  `get_item/1` gets a single Item.

  Returns nil if the Item does not exist

  ## Examples

      iex> get_item(1)
      %Timer{}

      iex> get_item(1313)
      nil
  """
  def get_item(id, preload_tags \\ false) do
    item =
      Item
      |> Repo.get(id)

    if(preload_tags == true) do
      item |> Repo.preload(tags: from(t in Tag, order_by: t.text))
    else
      item
    end
  end

  @doc """
  Returns the list of items where the status is different to "deleted"

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Item
    |> where([i], is_nil(i.status) or i.status != 6)
    |> Repo.all()
  end

  def list_person_items(person_id) do
    Item
    |> where(person_id: ^person_id)
    |> Repo.all()
    |> Repo.preload(tags: from(t in Tag, order_by: t.text))
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> PaperTrail.update(originator: %{id: Map.get(attrs, :person_id, 0)})
  end

  def update_draft(%Item{} = item, attrs) do
    item
    |> Item.draft_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Update an item and its associated tags
  """

  # def update_item_with_tags(%Item{} = item, attrs) do
  #  item
  #  |> Item.changeset_with_tags(attrs)
  #  |> Repo.update()
  # end

  def delete_item(id) do
    get_item!(id)
    |> Item.changeset(%{status: 6})
    |> Repo.update()
  end

  @doc """
  Switches the position of two items.
  This is used for drag and drop.
  """
  def move_item(id_from, id_to) do
    #  Get information of the two items
    item_from = get_item!(id_from)
    itemPosition_from = Map.get(item_from, :position)

    item_to = get_item!(id_to)
    itemPosition_to = Map.get(item_to, :position)

    # Switching the `position` field of both items
    {:ok, %{model: _item, version: _version}} =
      update_item(item_from, %{position: itemPosition_to})

    {:ok, %{model: _item, version: _version}} =
      update_item(item_to, %{position: itemPosition_from})
  end

  defp reorder_list_to_add_item(%Item{position: position}) do
    # Increments the positions above a given position.
    # We are making space for the item to be added.

    from(i in Item,
      where: i.position > ^position,
      update: [inc: [position: 1]]
    )
    |> Repo.update_all([])
  end

  #  🐲       H E R E   B E   D R A G O N S!     🐉
  #  ⏳     Working with Time is all Dragons!    🙄
  #  👩‍💻   Feedback/Pairing/Refactoring Welcome!  🙏

  @doc """
  `items_with_timers/1` Returns a List of items with the latest associated timers.
  This list is ordered with the position that is detailed inside the Items schema.

  ## Examples

  iex> items_with_timers()
  [
    %{text: "hello", person_id: 1, status: 2, start: 2022-07-14 09:35:18},
    %{text: "world", person_id: 2, status: 7, start: 2022-07-15 04:20:42}
  ]
  """
  #
  def items_with_timers(person_id \\ 0) do
    sql = """

    SELECT i.id, i.text, i.status, i.person_id, i.position, t.start, t.stop, t.id as timer_id FROM items i
    FULL JOIN timers as t ON t.item_id = i.id
    WHERE i.person_id = $1 AND i.status IS NOT NULL
    ORDER BY i.position ASC;

    """

    values =
      Ecto.Adapters.SQL.query!(Repo, sql, [person_id])
      |> map_columns_to_values()

    items_tags =
      list_person_items(person_id)
      |> Enum.reduce(%{}, fn i, acc -> Map.put(acc, i.id, i) end)

    accumulate_item_timers(values)
    |> Enum.map(fn t ->
      Map.put(t, :tags, items_tags[t.id].tags)
    end)
    |> Enum.sort_by(& &1.position)
  end

  @doc """
  `person_with_item_and_timer_count/0` returns a list of number of timers and items per person.
  Used mainly for metric-tracking purposes.

  ## Examples

  iex> person_with_item_and_timer_count()
  [
    %{name: nil, num_items: 3, num_timers: 8, person_id: 0}
    %{name: username, num_items: 1, num_timers: 3, person_id: 1}
  ]
  """
  def person_with_item_and_timer_count() do
    sql = """
    SELECT i.person_id,
    COUNT(distinct i.id) AS "num_items",
    COUNT(distinct t.id) AS "num_timers"
    FROM items i
    LEFT JOIN timers t ON t.item_id = i.id
    GROUP BY i.person_id
    ORDER BY i.person_id
    """

    Ecto.Adapters.SQL.query!(Repo, sql)
    |> map_columns_to_values()
  end

  @doc """
  `map_columns_to_values/1` takes an Ecto SQL query result
  which has the List of columns and rows separate
  and returns a List of Maps where the keys are the column names and values the data.

  Sadly, Ecto returns rows without column keys so we have to map them manually:
  ref: https://groups.google.com/g/elixir-ecto/c/0cubhSd3QS0/m/DLdQsFrcBAAJ
  """
  def map_columns_to_values(res) do
    Enum.map(res.rows, fn row ->
      Enum.zip(res.columns, row)
      |> Map.new()
      |> AtomicMap.convert(safe: false)
    end)
  end

  @doc """
  `map_timer_diff/1` transforms a list of items_with_timers
  into a flat map where the key is the timer_id and the value is the difference
  between timer.stop and timer.start
  If there is no active timer return {0, 0}.
  If there is no timer.stop return Now - timer.start

  ## Examples

  iex> list = [
    %{ stop: nil, id: 3, start: nil, timer_id: nil },
    %{ stop: ~N[2022-07-17 11:18:24], id: 1, start: ~N[2022-07-17 11:18:18], timer_id: 1 },
    %{ stop: ~N[2022-07-17 11:18:31], id: 1, start: ~N[2022-07-17 11:18:26], timer_id: 2 },
    %{ stop: ~N[2022-07-17 11:18:24], id: 2, start: ~N[2022-07-17 11:18:00], timer_id: 3 },
    %{ stop: nil, id: 2, start: seven_seconds_ago, timer_id: 4 }
  ]
  iex> map_timer_diff(list)
  %{0 => 0, 1 => 6, 2 => 5, 3 => 24, 4 => 7}
  """
  def map_timer_diff(list) do
    Map.new(list, fn item ->
      if is_nil(item.timer_id) do
        # item without any active timer
        {0, 0}
      else
        {item.timer_id, timer_diff(item)}
      end
    end)
  end

  @doc """
  `timer_diff/1` calculates the difference between timer.stop and timer.start
  If there is no active timer OR timer has not ended return 0.
  The reasoning is: an *active* timer (no end) does not have to
  be subtracted from the timer.start in the UI ...
  Again, DRAGONS!
  """
  def timer_diff(timer) do
    # ignore timers that have not ended (current timer is factored in the UI!)
    if is_nil(timer.stop) do
      0
    else
      NaiveDateTime.diff(timer.stop, timer.start)
    end
  end

  @doc """
  `accumulate_item_timers/1` aggregates the elapsed time
  for all the timers associated with an item
  and then subtract that time from the start value of the *current* active timer.
  This is done to create the appearance that a single timer is being started/stopped
  when in fact there are multiple timers in the backend.
  For MVP we *could* have just had a single timer ...
  and given the "ugliness" of this code, I wish I had done that!!
  But the "USP" of our product [IMO] is that
  we can track the completion of a task across multiple work sessions.
  And having multiple timers is the *only* way to achieve that.

  If you can think of a better way of achieving the same result,
  please share: https://github.com/dwyl/app-mvp-phoenix/issues/103
  This function *relies* on the list of items being ordered by timer_id ASC
  because it "pops" the last timer and ignores it to avoid double-counting.
  """
  def accumulate_item_timers(items_with_timers) do
    # e.g: %{0 => 0, 1 => 6, 2 => 5, 3 => 24, 4 => 7}
    timer_id_diff_map = map_timer_diff(items_with_timers)

    # e.g: %{1 => [2, 1], 2 => [4, 3], 3 => []}
    item_id_timer_id_map =
      Map.new(items_with_timers, fn i ->
        {i.id,
         Enum.map(items_with_timers, fn it ->
           if i.id == it.id, do: it.timer_id, else: nil
         end)
         # stackoverflow.com/questions/46339815/remove-nil-from-list
         |> Enum.reject(&is_nil/1)}
      end)

    # this one is "wasteful" but I can't think of how to simplify it ...
    item_id_timer_diff_map =
      Map.new(items_with_timers, fn item ->
        timer_id_list = Map.get(item_id_timer_id_map, item.id, [0])
        # Remove last item from list before summing to avoid double-counting
        {_, timer_id_list} = List.pop_at(timer_id_list, -1)

        {item.id,
         Enum.reduce(timer_id_list, 0, fn timer_id, acc ->
           Map.get(timer_id_diff_map, timer_id) + acc
         end)}
      end)

    # creates a nested map: %{ item.id: %{id: 1, text: "my item", etc.}}
    Map.new(items_with_timers, fn item ->
      time_elapsed = Map.get(item_id_timer_diff_map, item.id)

      start =
        if is_nil(item.start),
          do: nil,
          else: NaiveDateTime.add(item.start, -time_elapsed)

      {item.id, %{item | start: start}}
    end)
    # Return the list of items without duplicates and only the last/active timer:
    |> Map.values()
    # Sort list by item.id descending (ordered by timer_id ASC above) so newest item first:
    |> Enum.sort_by(fn i -> i.id end, :desc)
  end
end
