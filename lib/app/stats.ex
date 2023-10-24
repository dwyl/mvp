defmodule App.Stats do
  alias App.Repo
  require Logger

  @doc """
  `person_with_item_and_timer_count/2` returns a list of number of timers and items per person
  sorted by column and order
  Used mainly for metric-tracking purposes.

  ## Sample:

  App.Stats.person_with_item_and_timer_count()
  [
    %{name: nil, num_items: 3, num_timers: 8, person_id: 0},
    %{name: "username", num_items: 1, num_timers: 3, person_id: 1}
  ]

  App.Stats.person_with_item_and_timer_count(:person_id, :desc)
  [
    %{name: "username", num_items: 1, num_timers: 3, person_id: 1},
    %{name: nil, num_items: 3, num_timers: 8, person_id: 0}
  ]
  """
  def person_with_item_and_timer_count(
        sort_column \\ :person_id,
        sort_order \\ :asc
      ) do
    sort_column = to_string(sort_column)
    sort_order = to_string(sort_order)

    sort_column =
      if validate_sort_column(sort_column), do: sort_column, else: "person_id"

    sort_order = if Repo.validate_order(sort_order), do: sort_order, else: "asc"

    sql = """
    SELECT i.person_id,
    COUNT(distinct i.id) AS "num_items",
    COUNT(distinct t.id) AS "num_timers",
    MIN(i.inserted_at) AS "first_inserted_at",
    MAX(i.inserted_at) AS "last_inserted_at",
    SUM(EXTRACT(EPOCH FROM (t.stop - t.start))) AS "total_timers_in_seconds"
    FROM items i
    LEFT JOIN timers t ON t.item_id = i.id
    GROUP BY i.person_id
    ORDER BY #{sort_column} #{sort_order}
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
  `validate_sort_column/1` validates the column name is in items columns
  to make sure it's a valid column passed.

  ## Examples

      iex> App.Stats.validate_sort_column("person_id")
      true

      iex> App.Stats.validate_sort_column(:invalid)
      false

      # Avoid ";" character used SQL Injection: e.g: "; DROP TABLE items"
      iex> App.Stats.validate_sort_column(";")
      false
  """
  def validate_sort_column(column) do
    Enum.member?(
      ~w(person_id num_items num_timers first_inserted_at last_inserted_at total_timers_in_seconds),
      column
    )
  end
end
