defmodule AppWeb.AppLive do
  require Logger

  use AppWeb, :live_view
  alias App.{Item, Timer}
  # run authentication on mount
  on_mount AppWeb.AuthController
  alias Phoenix.Socket.Broadcast

  @topic "live"

  defp get_person_id(assigns), do: assigns[:person][:id] || 0

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@topic)

    person_id = get_person_id(socket.assigns)
    items = Item.items_with_timers(person_id)

    {:ok,
     assign(socket,
       items: items,
       editing_timers: [],
       editing: nil,
       filter: "active",
       filter_tag: nil
     )}
  end

  @impl true
  def handle_event("create", %{"text" => text, "tags" => tags}, socket) do
    person_id = get_person_id(socket.assigns)

    Item.create_item_with_tags(%{
      text: text,
      person_id: person_id,
      status: 2,
      tags: tags
    })

    AppWeb.Endpoint.broadcast(@topic, "update", :create)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    status = if Map.has_key?(data, "value"), do: 4, else: 3

    # need to restrict getting items to the people who own or have rights to access them!
    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{status: status})
    Timer.stop_timer_for_item_id(item.id)

    AppWeb.Endpoint.broadcast(@topic, "update", :toggle)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => item_id}, socket) do
    Item.delete_item(item_id)
    AppWeb.Endpoint.broadcast(@topic, "update", :delete)
    {:noreply, socket}
  end

  @impl true
  def handle_event("start", data, socket) do
    item = Item.get_item!(Map.get(data, "id"))
    person_id = get_person_id(socket.assigns)

    {:ok, _timer} =
      Timer.start(%{
        item_id: item.id,
        person_id: person_id,
        start: NaiveDateTime.utc_now()
      })

    AppWeb.Endpoint.broadcast(@topic, "update", :start)
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", data, socket) do
    timer_id = Map.get(data, "timerid")
    {:ok, _timer} = Timer.stop(%{id: timer_id})

    AppWeb.Endpoint.broadcast(@topic, "update", :stop)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit-item", data, socket) do
    item_id = String.to_integer(data["id"])

    timers_list = Timer.list_timers(item_id)

    timers_list_changeset =
      Enum.map(timers_list, fn t ->
        Timer.changeset(t, %{
          id: t.id,
          start: t.start,
          stop: t.stop,
          item_id: t.item_id
        })
      end)

    {:noreply,
     assign(socket, editing: item_id, editing_timers: timers_list_changeset)}
  end

  @impl true
  def handle_event(
        "update-item",
        %{"id" => item_id, "text" => text, "tags" => tags},
        socket
      ) do
    person_id = get_person_id(socket.assigns)
    current_item = Item.get_item!(item_id)

    Item.update_item_with_tags(current_item, %{
      text: text,
      tags: tags,
      person_id: person_id
    })

    AppWeb.Endpoint.broadcast(@topic, "update", :update)
    {:noreply, assign(socket, editing: nil, editing_timers: [])}
  end

  @impl true
  def handle_event(
        "update-item-timer",
        %{
          "timer_id" => id,
          "index" => index,
          "timer_start" => timer_start,
          "timer_stop" => timer_stop
        },
        socket
      ) do
    timer_changeset_list = socket.assigns.editing_timers
    index = String.to_integer(index)
    changeset_obj = Enum.at(timer_changeset_list, index)

    try do
      start =
        App.DateTimeParser.parse!(timer_start, "%Y-%m-%dT%H:%M:%S")
        |> DateTime.to_naive()

      stop =
        App.DateTimeParser.parse!(timer_stop, "%Y-%m-%dT%H:%M:%S")
        |> DateTime.to_naive()

      case NaiveDateTime.compare(start, stop) do
        :lt ->
          # Creates a list of all other timers to check for overlap
          other_timers_list =
            List.delete_at(socket.assigns.editing_timers, index)

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

            # Timer.update_timer(%{id: id, start: start, stop: stop})
            {:noreply, assign(socket, editing: nil, editing_timers: [])}
          catch
            :overlap ->
              updated_changeset_timers_list =
                error_timer_changeset(
                  timer_changeset_list,
                  changeset_obj,
                  index,
                  :id,
                  "This timer interval overlaps with other timers. Make sure all the timers are correct and don't overlap with each other"
                )

              {:noreply,
               assign(socket, editing_timers: updated_changeset_timers_list)}
          end

        :eq ->
          updated_changeset_timers_list =
            error_timer_changeset(
              timer_changeset_list,
              changeset_obj,
              index,
              :id,
              "Start or stop are equal."
            )

          {:noreply,
           assign(socket, editing_timers: updated_changeset_timers_list)}

        :gt ->
          updated_changeset_timers_list =
            error_timer_changeset(
              timer_changeset_list,
              changeset_obj,
              index,
              :id,
              "Start is newer that stop."
            )

          {:noreply,
           assign(socket, editing_timers: updated_changeset_timers_list)}
      end
    rescue
      _e ->
        updated_changeset_timers_list =
          error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Date format invalid on either start or stop."
          )

        {:noreply,
         assign(socket, editing_timers: updated_changeset_timers_list)}
    end
  end

  # Errors a specific changeset from a list of changesets and returns the updated list of changesets.
  # You should pass a:
  # - `timer_changeset_list: list of timer changesets to be updated
  # - `changeset_to_error`: changeset object that you want to error out
  # - `changeset_index`: changeset object index inside the list of timer changesets
  # - `changeset_error_key`: atom key of the changeset object you want to associate the error message
  # - `changeset_error_message`: the string message to error the changeset key with.
  @doc false
  defp error_timer_changeset(
         timer_changeset_list,
         changeset_to_error,
         changeset_index,
         changeset_error_key,
         changeset_error_message
       ) do
    # Clearing and adding error to changeset
    cleared_changeset = Map.put(changeset_to_error, :errors, [])

    errored_changeset =
      Ecto.Changeset.add_error(
        cleared_changeset,
        changeset_error_key,
        changeset_error_message
      )

    {_reply, errored_changeset} =
      Ecto.Changeset.apply_action(errored_changeset, :update)

    #  Updated list with errored changeset
    List.replace_at(timer_changeset_list, changeset_index, errored_changeset)
  end

  @impl true
  def handle_info(%Broadcast{event: "update", payload: _message}, socket) do
    person_id = get_person_id(socket.assigns)
    items = Item.items_with_timers(person_id)

    {:noreply, assign(socket, items: items)}
  end

  # only show certain UI elements (buttons) if there are items:
  def has_items?(items), do: length(items) > 1

  # 2: uncategorised (when item are created), 3: active
  def active?(item), do: item.status == 2 || item.status == 3
  def done?(item), do: item.status == 4
  def archived?(item), do: item.status == 6

  # Check if an item has an active timer
  def started?(item) do
    not is_nil(item.start) and is_nil(item.stop)
  end

  # An item without an end should be counting
  def timer_stopped?(item) do
    not is_nil(item.stop)
  end

  def timers_any?(item) do
    not is_nil(item.timer_id)
  end

  # Convert Elixir NaiveDateTime to JS (Unix) Timestamp
  def timestamp(naive_datetime) do
    DateTime.from_naive!(naive_datetime, "Etc/UTC")
    |> DateTime.to_unix(:millisecond)
  end

  # Elixir implementation of `timer_text/2`
  def left_pad(val) do
    if val < 10, do: "0#{to_string(val)}", else: val
  end

  def timer_text(item) do
    if is_nil(item) or is_nil(item.start) or is_nil(item.stop) do
      ""
    else
      diff = timestamp(item.stop) - timestamp(item.start)

      # seconds
      s =
        if diff > 1000 do
          s = (diff / 1000) |> trunc()
          s = if s > 60, do: Integer.mod(s, 60), else: s
          left_pad(s)
        else
          "00"
        end

      # minutes
      m =
        if diff > 60_000 do
          m = (diff / 60_000) |> trunc()
          m = if m > 60, do: Integer.mod(m, 60), else: m
          left_pad(m)
        else
          "00"
        end

      # hours
      h =
        if diff > 3_600_000 do
          h = (diff / 3_600_000) |> trunc()
          left_pad(h)
        else
          "00"
        end

      "#{h}:#{m}:#{s}"
    end
  end

  # Filter element by status (active, archived & done; default: all)
  # see https://hexdocs.pm/phoenix_live_view/live-navigation.html
  @impl true
  def handle_params(params, _uri, socket) do
    filter = params["filter_by"] || socket.assigns.filter

    filter_tag = params["filter_by_tag"]

    {:noreply, assign(socket, filter: filter, filter_tag: filter_tag)}
  end

  defp filter_items(items, filter, filter_tag) do
    items =
      case filter do
        "active" ->
          Enum.filter(items, &active?(&1))

        "done" ->
          Enum.filter(items, &done?(&1))

        "archived" ->
          Enum.filter(items, &archived?(&1))

        _ ->
          items
      end

    if not is_nil(filter_tag) do
      items
      |> Enum.filter(fn item ->
        Enum.any?(item.tags, fn tag -> tag.text == filter_tag end)
      end)
    else
      items
    end
  end

  def class_footer_link(filter_name, filter_selected) do
    if filter_name == filter_selected do
      "px-2 py-2 h-9 mr-1 bg-teal-700 text-white rounded-md"
    else
      """
      py-2 px-4 bg-transparent font-semibold
      border rounded border-teal-700 text-teal-700
      hover:text-white hover:bg-teal-800 hover:border-transparent
      """
    end
  end

  @doc """
  Convert a list of tags to a string where
  the tag names are seperated by commas

  ## Examples

    tags_to_string([%Tag{text: "Learn"}, %Tag{text: "Elixir"}])
    "Learn, Elixir"

  """
  def tags_to_string(tags), do: Enum.map_join(tags, ", ", & &1.text)
end
