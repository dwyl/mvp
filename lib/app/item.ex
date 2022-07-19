defmodule App.Item do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias App.Repo
  alias __MODULE__

  schema "items" do
    field :text, :string
    field :status_code, :integer
    field :person_id, :integer
    
    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:text, :status_code, :person_id])
    |> validate_required([:text])
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{text: "Learn LiveView"})
      {:ok, %Item{}}

      iex> create_item(%{text: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs) do
    %Item{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Returns the list of items where the status is different to "deleted"

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Item
    |> order_by(desc: :inserted_at)
    |> where([i], is_nil(i.status_code) or i.status_code != 6)
    |> Repo.all()
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
    |> Repo.update()
  end

  def delete_item(id) do
    get_item!(id)
    |> Item.changeset(%{status_code: 6})
    |> Repo.update()
  end


  #  🐲       H E R E   B E   D R A G O N S!     🐉
  #  ⏳     Working with Time is all Dragons!    🙄
  #  👩‍💻   Feedback/Pairing/Refactoring Welcome!  🙏

  @doc """
  `items_with_timers/1` Returns a List of items with the latest associated timers.
  
  ## Examples

  iex> items_with_timers()
  [
    %{text: "hello", person_id: 1, status_code: 2, start: 2022-07-14 09:35:18},
    %{text: "world", person_id: 2, status_code: 7, start: 2022-07-15 04:20:42}
  ]
  """
  # 
  def items_with_timers(person_id \\ 1) do
    sql = """
    SELECT i.id, i.text, i.status_code, i.person_id, t.start, t.end, t.id as timer_id FROM items i
    FULL JOIN timers as t ON t.item_id = i.id
    WHERE i.person_id = $1 AND i.status_code IS NOT NULL AND i.status_code != 6
    ORDER BY timer_id ASC;
    """

    Ecto.Adapters.SQL.query!(Repo, sql, [person_id])
    |> map_columns_to_values()
    |> accumulate_item_timers()
  end


  @doc """
  `map_columns_to_values/1` takes an Ecto SQL query result
  which has the List of columns and rows separate
  and returns a List of Maps where the keys are the column names and values the data.

  Sadly, Ecto returns rows without column keys so we have to map them manually:
  ref: https://groups.google.com/g/elixir-ecto/c/0cubhSd3QS0/m/DLdQsFrcBAAJ
  """

  defp map_columns_to_values(res) do
    Enum.map(res.rows, fn(row) ->
      Enum.zip(res.columns, row) 
      |> Map.new |> AtomicMap.convert()
    end)
  end

  @doc """
  `map_timer_diff/1` transforms a list of items_with_timers
  into a flat map where the key is the timer_id and the value is the difference
  between timer.end and timer.start 
  If there is no active timer return {0, 0}.
  If there is no timer.end return Now - timer.start

  ## Examples

  iex> list = [
    %{ end: nil, id: 3, start: nil, timer_id: nil },
    %{ end: ~N[2022-07-17 11:18:24], id: 1, start: ~N[2022-07-17 11:18:18], timer_id: 1 },
    %{ end: ~N[2022-07-17 11:18:31], id: 1, start: ~N[2022-07-17 11:18:26], timer_id: 2 },
    %{ end: ~N[2022-07-17 11:18:24], id: 2, start: ~N[2022-07-17 11:18:00], timer_id: 3 },
    %{ end: nil, id: 2, start: seven_seconds_ago, timer_id: 4 }
  ]
  iex> map_timer_diff(list)
  %{0 => 0, 1 => 6, 2 => 5, 3 => 24, 4 => 7}
  """
  def map_timer_diff(list) do
    Map.new(list, fn item ->
      if is_nil(item.timer_id) do
        # item without any active timer
        { 0, 0}
      else
        { item.timer_id, timer_diff(item)}
      end  
    end)
  end

  @doc """
  `timer_diff/1` calculates the difference between timer.end and timer.start 
  If there is no active timer OR timer has not ended return 0.
  The reasoning is: an *active* timer (no end) does not have to
  be subtracted from the timer.start in the UI ... 
  Again, DRAGONS! 
  """
  def timer_diff(timer) do
    # ignore timers that have not ended (current timer is factored in the UI!)
    if is_nil(timer.end) do
      0
    else 
      NaiveDateTime.diff(timer.end, timer.start)
    end
  end

  @doc """
  `accumulate_item_timers/1` aggregates the elapsed time 
  for all the timers associated with an item
  and then subtracs that time from the start value of the *current* active timer.
  This is done to create the appearance that a single timer is being started/stopped
  when in fact there are multiple timers in the backend. 
  For MVP we *could* have just had a single timer ... 
  and given the "ugliness" of this code, I wish I had done that!!
  But the "USP" of our product [IMO] is that 
  we can track the completion of a task across multiple work sessions.
  And having multiple timers is the *only* way to achieve that.

  If you can think of a better way of achieving the same result,
  please share: https://github.com/dwyl/app-mvp-phoenix/issues/103
  This function *relies* on the list of items being orderd by timer_id ASC
  because it "pops" the last timer and ignores it to avoid double-counting.
  """
  def accumulate_item_timers(items_with_timers) do
    # e.g: %{0 => 0, 1 => 6, 2 => 5, 3 => 24, 4 => 7}
    timer_id_diff_map = map_timer_diff(items_with_timers)

    # e.g: %{1 => [2, 1], 2 => [4, 3], 3 => []}
    item_id_timer_id_map = Map.new(items_with_timers, fn i -> 
      { i.id, Enum.map(items_with_timers, fn it -> 
          if i.id == it.id, do: it.timer_id, else: nil
        end)
        # stackoverflow.com/questions/46339815/remove-nil-from-list
        |> Enum.reject(&is_nil/1)
      } 
    end)

    # this one is "wasteful" but I can't think of how to simplify it ...
    item_id_timer_diff_map = Map.new(items_with_timers, fn item -> 
      timer_id_list = Map.get(item_id_timer_id_map, item.id, [0])
      # Remove last item from list before summing to avoid double-counting
      {_, timer_id_list} = List.pop_at(timer_id_list, -1)
      
      { item.id, Enum.reduce(timer_id_list, 0, fn timer_id, acc -> 
          Map.get(timer_id_diff_map, timer_id) + acc 
        end)
      }
    end)

    # creates a nested map: %{ item.id: %{id: 1, text: "my item", etc.}}
    Map.new(items_with_timers, fn item -> 
      time_elapsed = Map.get(item_id_timer_diff_map, item.id)
      start = if is_nil(item.start), do: nil, 
        else: NaiveDateTime.add(item.start, -time_elapsed)

      { item.id, %{item | start: start}}
    end)
    # Return the list of items without duplicates and only the last/active timer:
    |> Map.values()
    # Sort list by item.id descending (ordered by timer_id ASC above) so newest item first:
    |> Enum.sort_by(fn(i) -> i.id end, :desc)
  end
end
