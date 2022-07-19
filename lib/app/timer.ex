defmodule App.Timer do
  use Ecto.Schema
  import Ecto.Changeset
  # import Ecto.Query
  alias App.Repo
  alias __MODULE__
  require Logger

  schema "timers" do
    field :end, :naive_datetime
    field :start, :naive_datetime
    field :item_id, :id
    field :person_id, :id

    timestamps()
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [:item_id, :start, :end, :person_id])
    |> validate_required([:item_id, :start])
  end

  @doc """
  `get_timer/1` gets a single Timer.

  Raises `Ecto.NoResultsError` if the Timer does not exist.

  ## Examples

      iex> get_timer!(123)
      %Timer{}
  """
  def get_timer!(id), do: Repo.get!(Timer, id)


  @doc """
  `start/1` starts a timer.

  ## Examples

      iex> start(%{item_id: 1, })
      {:ok, %Timer{start: ~N[2022-07-11 04:20:42]}}

  """
  def start(attrs \\ %{}) do
    %Timer{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  `stop/1` stops a timer.

  ## Examples

      iex> stop(%{id: 1})
      {:ok, %Timer{end: ~N[2022-07-11 05:15:31], etc.}}

  """
  def stop(attrs \\ %{}) do
    get_timer!(attrs.id)
    |> changeset(%{end: NaiveDateTime.utc_now})
    |> Repo.update()
  end

  @doc """
  `stop_timer_for_item_id/1` stops a timer for the given item_id if there is one.
  Fails silently if there is no timer for the given item_id.

  ## Examples

      iex> stop_timer_for_item_id(42)
      {:ok, %Timer{item_id: 42, end: ~N[2022-07-11 05:15:31], etc.}}

  """
  def stop_timer_for_item_id(item_id) when is_nil(item_id) do
    Logger.debug("stop_timer_for_item_id/1 called without item_id: #{item_id} fail.")
  end

  def stop_timer_for_item_id(item_id) do
    # get timer by item_id find the latest one that has not been stopped:
    sql = """
    SELECT t.id FROM timers t WHERE t.item_id = $1 AND t.end IS NULL ORDER BY t.id DESC LIMIT 1;
    """
    res = Ecto.Adapters.SQL.query!(Repo, sql, [item_id])
    
    if res.num_rows > 0 do
      # IO.inspect(res.rows)
      timer_id = res.rows |> List.first() |> List.first()
      Logger.debug("Found timer.id: #{timer_id} for item: #{item_id}, attempting to stop.")
      stop(%{id: timer_id})
    else
      Logger.debug("No active timers found for item: #{item_id}")
    end
  end
end
