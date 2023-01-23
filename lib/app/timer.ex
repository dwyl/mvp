defmodule App.Timer do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias App.{Item, Repo}
  alias __MODULE__
  require Logger

  @derive {Jason.Encoder, only: [:id, :start, :stop]}
  schema "timers" do
    field :start, :naive_datetime
    field :stop, :naive_datetime
    belongs_to :item, Item, references: :id, foreign_key: :item_id

    timestamps()
  end

  defp validate_start_before_stop(changeset) do
    start = get_field(changeset, :start)
    stop = get_field(changeset, :stop)

    # If start or stop  is nil, no comparison occurs.
    case is_nil(stop) or is_nil(start) do
      true ->
        changeset

      false ->
        if NaiveDateTime.compare(start, stop) == :gt do
          add_error(changeset, :start, "cannot be later than 'stop'")
        else
          changeset
        end
    end
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [:item_id, :start, :stop])
    |> validate_required([:item_id, :start])
  end

  @doc """
  `get_timer!/1` gets a single Timer.

  Raises `Ecto.NoResultsError` if the Timer does not exist.

  ## Examples

      iex> get_timer!(123)
      %Timer{}
  """
  def get_timer!(id), do: Repo.get!(Timer, id)

  @doc """
  `get_timer/1` gets a single Timer.

  Returns nil if the Timer does not exist

  ## Examples

      iex> get_timer(1)
      %Timer{}

      iex> get_item!(13131)
      nil
  """
  def get_timer(id), do: Repo.get(Timer, id)

  @doc """
  `list_timers/1` lists all the timer objects of a given item `id`.

    ## Examples

      iex> list_timers(1)
      [
        %App.Timer{
          id: 7,
          start: ~N[2023-01-11 17:40:44],
          stop: nil,
          item_id: 1,
          inserted_at: ~N[2023-01-11 18:01:43],
          updated_at: ~N[2023-01-11 18:01:43]
        }
      ]
  """
  def list_timers(item_id) do
    Timer
    |> where(item_id: ^item_id)
    |> order_by(:id)
    |> Repo.all()
  end

  @doc """
  `start/1` starts a timer.

  ## Examples

      iex> start(%{item_id: 1, })
      {:ok, %Timer{start: ~N[2022-07-11 04:20:42]}}

  """
  def start(attrs \\ %{}) do
    %Timer{}
    |> changeset(attrs)
    |> validate_start_before_stop()
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
  def update_timer(%Timer{} = timer, attrs \\ %{}) do
    timer
    |> changeset(attrs)
    |> validate_start_before_stop()
    |> Repo.update()
  end

  @doc """
  Updates a timer object inside a list with timer changesets.
  This function is only useful for form validations, since it replaces the errored changeset
  according to the index that is passed, alongside the list and the fields to update the timer.

  It returns {:ok, []} in case the update is successful.
  Otherwise, it returns {:error, updated_list}, where `error_term` is the error that occurred and `updated_list` being the updated item changeset list with the error.
  """
  def update_timer_inside_changeset_list(
        %{
          id: timer_id,
          start: timer_start,
          stop: timer_stop
        },
        index,
        timer_changeset_list
      )
      when timer_stop == "" or timer_stop == nil do
    # Getting the changeset to change in case there's an error
    changeset_obj = Enum.at(timer_changeset_list, index)

    try do
      # Parsing the dates
      {start_op, start} =
        Timex.parse(timer_start, "%Y-%m-%dT%H:%M:%S", :strftime)

      # Error guards when parsing the date
      if start_op === :error do
        throw(:error_invalid_start)
      end

      # Getting a list of the other timers (the rest we aren't updating)
      other_timers_list = List.delete_at(timer_changeset_list, index)

      # Latest timer end
      max_end =
        other_timers_list |> Enum.map(fn chs -> chs.data.stop end) |> Enum.max()

      case NaiveDateTime.compare(start, max_end) do
        :gt ->
          timer = get_timer(timer_id)
          update_timer(timer, %{start: start, stop: nil})
          {:ok, []}

        _ ->
          throw(:error_not_after_others)
      end
    catch
      :error_invalid_start ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Start field has an invalid date format.",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_not_after_others ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "When editing an ongoing timer, make sure it's after all the others.",
            :update
          )

        {:error, updated_changeset_timers_list}
    end
  end

  def update_timer_inside_changeset_list(
        %{
          id: timer_id,
          start: timer_start,
          stop: timer_stop
        },
        index,
        timer_changeset_list
      ) do
    # Getting the changeset to change in case there's an error
    changeset_obj = Enum.at(timer_changeset_list, index)

    try do
      # Parsing the dates
      {start_op, start} =
        Timex.parse(timer_start, "%Y-%m-%dT%H:%M:%S", :strftime)

      {stop_op, stop} = Timex.parse(timer_stop, "%Y-%m-%dT%H:%M:%S", :strftime)

      # Error guards when parsing the dates
      if start_op === :error do
        throw(:error_invalid_start)
      end

      if stop_op === :error do
        throw(:error_invalid_stop)
      end

      case NaiveDateTime.compare(start, stop) do
        :lt ->
          # Creates a list of all other timers to check for overlap
          other_timers_list = List.delete_at(timer_changeset_list, index)

          # Timer overlap verification ---------
          for chs <- other_timers_list do
            chs_start = chs.data.start
            chs_stop = chs.data.stop

            # If the timer being compared is ongoing
            if chs_stop == nil do
              compareStart = NaiveDateTime.compare(start, chs_start)
              compareEnd = NaiveDateTime.compare(stop, chs_start)

              # The condition needs to FAIL so the timer doesn't overlap
              if compareStart == :lt && compareEnd == :gt do
                throw(:error_overlap)
              end

              # Else the timer being compared is historical
            else
              # The condition needs to FAIL (StartA <= EndB) and (EndA >= StartB)
              # so no timer overlaps one another
              compareStartAEndB = NaiveDateTime.compare(start, chs_stop)
              compareEndAStartB = NaiveDateTime.compare(stop, chs_start)

              if(
                (compareStartAEndB == :lt || compareStartAEndB == :eq) &&
                  (compareEndAStartB == :gt || compareEndAStartB == :eq)
              ) do
                throw(:error_overlap)
              end
            end
          end

          timer = get_timer(timer_id)
          update_timer(timer, %{start: start, stop: stop})
          {:ok, []}

        :eq ->
          throw(:error_start_equal_stop)

        :gt ->
          throw(:error_start_greater_than_stop)
      end
    catch
      :error_invalid_start ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Start field has an invalid date format.",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_invalid_stop ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Stop field has an invalid date format.",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_overlap ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "This timer interval overlaps with other timers. Make sure all the timers are correct and don't overlap with each other",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_start_equal_stop ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Start or stop are equal.",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_start_greater_than_stop ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Start is newer that stop.",
            :update
          )

        {:error, updated_changeset_timers_list}
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
    Logger.info(
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
      timer_id = res.rows |> List.first() |> List.first()

      Logger.info(
        "Found timer.id: #{timer_id} for item: #{item_id}, attempting to stop."
      )

      stop(%{id: timer_id})
    else
      Logger.debug("No active timers found for item: #{item_id}")
    end
  end
end
