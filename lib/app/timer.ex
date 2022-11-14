defmodule App.Timer do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Item
  import Ecto.Query
  # import Ecto.Query
  alias App.Repo
  alias __MODULE__
  require Logger

  schema "timers" do
    field :start, :naive_datetime
    field :stop, :naive_datetime
    belongs_to :item, Item, references: :id, foreign_key: :item_id

    timestamps()
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [:item_id, :start, :stop])
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
      {:ok, %Timer{stop: ~N[2022-07-11 05:15:31], etc.}}

  """
  def stop(attrs \\ %{}) do
    get_timer!(attrs.id)
    |> changeset(%{stop: NaiveDateTime.utc_now()})
    |> Repo.update()
  end

  @doc """
  Updates a timer object.

  ## Examples

      iex> update_timer(%{id: 1, start: ~N[2022-07-11 05:15:31], stop: ~N[2022-07-11 05:15:37]})
      {:ok, %Timer{id: 1, start: ~N[2022-07-11 05:15:31], stop: ~N[2022-07-11 05:15:37}}

  """
  def update_timer(attrs \\ %{}) do
    get_timer!(attrs.id)
    |> changeset(attrs)
    |> Repo.update()
  end

  def update_timer_inside_changeset_list(
        timer_id,
        timer_start,
        timer_stop,
        index,
        timer_changeset_list
      ) do


    changeset_obj = Enum.at(timer_changeset_list, index)

    try do
      start = Timex.parse!(timer_start, "%Y-%m-%dT%H:%M:%S", :strftime)
      stop = Timex.parse!(timer_stop, "%Y-%m-%dT%H:%M:%S", :strftime)

      case NaiveDateTime.compare(start, stop) do
        :lt ->
          # Creates a list of all other timers to check for overlap
          other_timers_list = List.delete_at(timer_changeset_list, index)

          # Timer overlap verification
          try do
            for chs <- other_timers_list do
              chs_start = chs.data.start
              chs_stop = chs.data.stop

              # The condition needs to FAIL (StartA <= EndB) and (EndA >= StartB)
              # so no timer overlaps one another
              compareStartAEndB = NaiveDateTime.compare(start, chs_stop)
              compareEndAStartB = NaiveDateTime.compare(stop, chs_start)

              if(
                (compareStartAEndB == :lt || compareStartAEndB == :eq) &&
                  (compareEndAStartB == :gt || compareEndAStartB == :eq)
              ) do
                throw(:overlap)
              end
            end

            update_timer(%{id: timer_id, start: start, stop: stop})
            {:ok, []}
            # {:noreply, assign(socket, editing: nil, editing_timers: [])}
          catch
            :overlap ->
              updated_changeset_timers_list =
                Timer.error_timer_changeset(
                  timer_changeset_list,
                  changeset_obj,
                  index,
                  :id,
                  "This timer interval overlaps with other timers. Make sure all the timers are correct and don't overlap with each other",
                  :update
                )

              {:overlap, updated_changeset_timers_list}
              # {:noreply, assign(socket, editing_timers: updated_changeset_timers_list)}
          end

        :eq ->
          updated_changeset_timers_list =
            Timer.error_timer_changeset(
              timer_changeset_list,
              changeset_obj,
              index,
              :id,
              "Start or stop are equal.",
              :update
            )

          {:start_equal_stop, updated_changeset_timers_list}
          # {:noreply, assign(socket, editing_timers: updated_changeset_timers_list)}

        :gt ->
          updated_changeset_timers_list =
            Timer.error_timer_changeset(
              timer_changeset_list,
              changeset_obj,
              index,
              :id,
              "Start is newer that stop.",
              :update
            )

          {:start_greater_than_stop, updated_changeset_timers_list}
          # {:noreply, assign(socket, editing_timers: updated_changeset_timers_list)}
      end
    rescue
      _e ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Date format invalid on either start or stop.",
            :update
          )

        {:invalid_format, updated_changeset_timers_list}
        # {:noreply, assign(socket, editing_timers: updated_changeset_timers_list)}
    end
  end

  @doc """
  Lists all the timers changesets from a given item.id.
  This is useful for form validation, as it returns the timers in a changeset form, in which you can add errors.

  ## Examples

    iex> list_timers_changesets(1)
    [ #Ecto.Changeset<action: nil, changes: %{}, errors: [], data: #App.Timer<>, valid?: true> ]
  """
  def list_timers_changesets(item_id) do
    from(v in Timer, where: [item_id: ^item_id], order_by: [asc: :id])
    |> Repo.all()
    |> Enum.map(fn t ->
      Timer.changeset(t, %{
        id: t.id,
        start: t.start,
        stop: t.stop,
        item_id: t.item_id
      })
    end)
  end

  @doc """
   Errors a specific changeset from a list of changesets and returns the updated list of changesets.
   Should only be called for form validation purposes
   You should pass a:
   - `timer_changeset_list: list of timer changesets to be updated
   - `changeset_to_error`: changeset object that you want to error out
   - `changeset_index`: changeset object index inside the list of timer changesets (faster lookup)
   - `error_key`: atom key of the changeset object you want to associate the error message to
   - `error_message`: the string message to error the changeset key with.
   - `action`: action atom to apply to errored changeset.
  """
  def error_timer_changeset(
        timer_changeset_list,
        changeset_to_error,
        changeset_index,
        error_key,
        error_message,
        action
      ) do
    # Clearing and adding error to changeset
    cleared_changeset = Map.put(changeset_to_error, :errors, [])

    errored_changeset =
      Ecto.Changeset.add_error(
        cleared_changeset,
        error_key,
        error_message
      )

    {_reply, errored_changeset} =
      Ecto.Changeset.apply_action(errored_changeset, action)

    #  Updated list with errored changeset
    List.replace_at(timer_changeset_list, changeset_index, errored_changeset)
  end

  @doc """
  `stop_timer_for_item_id/1` stops a timer for the given item_id if there is one.
  Fails silently if there is no timer for the given item_id.

  ## Examples

      iex> stop_timer_for_item_id(42)
      {:ok, %Timer{item_id: 42, stop: ~N[2022-07-11 05:15:31], etc.}}

  """
  def stop_timer_for_item_id(item_id) when is_nil(item_id) do
    Logger.debug(
      "stop_timer_for_item_id/1 called without item_id: #{item_id} fail."
    )
  end

  def stop_timer_for_item_id(item_id) do
    # get timer by item_id find the latest one that has not been stopped:
    sql = """
    SELECT t.id FROM timers t WHERE t.item_id = $1 AND t.stop IS NULL ORDER BY t.id DESC LIMIT 1;
    """

    res = Ecto.Adapters.SQL.query!(Repo, sql, [item_id])

    if res.num_rows > 0 do
      # IO.inspect(res.rows)
      timer_id = res.rows |> List.first() |> List.first()

      Logger.debug(
        "Found timer.id: #{timer_id} for item: #{item_id}, attempting to stop."
      )

      stop(%{id: timer_id})
    else
      Logger.debug("No active timers found for item: #{item_id}")
    end
  end
end
