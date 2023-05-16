defmodule AppWeb.AppLive do
  require Logger
  use AppWeb, :live_view
  use Timex
  alias App.{Item, Tag, Timer}
  # run authentication on mount
  on_mount(AppWeb.AuthController)
  alias Phoenix.Socket.Broadcast

  @topic "live"
  @stats_topic "stats"

  defp get_person_id(assigns), do: assigns[:person][:id] || 0

  on_mount AppWeb.Hooks.LocalTimeZoneHook

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@topic)
    AppWeb.Endpoint.subscribe(@stats_topic)

    person_id = get_person_id(socket.assigns)
    items = Item.items_with_timers(person_id)
    tags = Tag.list_person_tags(person_id)
    selected_tags = []
    draft_item = Item.get_draft_item(person_id)

    {:ok,
     assign(socket,
       items: items,
       editing_timers: [],
       editing: nil,
       filter: "active",
       filter_tag: nil,
       tags: tags,
       selected_tags: selected_tags,
       text_value: draft_item.text || "",

       # Offset from the client to UTC. If it's "1", it means we are one hour ahead of UTC.
       hours_offset_fromUTC:
         get_connect_params(socket)["hours_offset_fromUTC"] || 0
     )}
  end

  @impl true
  def handle_event("validate", %{"text" => text}, socket) do
    person_id = get_person_id(socket.assigns)
    draft = Item.get_draft_item(person_id)
    Item.update_draft(draft, %{text: text})
    # only save draft if person id != 0 (ie not guest)
    {:noreply, assign(socket, text_value: text)}
  end

  @impl true
  def handle_event("create", %{"text" => text}, socket) do
    person_id = get_person_id(socket.assigns)

    Item.create_item_with_tags(%{
      text: text,
      person_id: person_id,
      status: 2,
      tags: socket.assigns.selected_tags
    })

    draft = Item.get_draft_item(person_id)
    Item.update_draft(draft, %{text: ""})

    AppWeb.Endpoint.broadcast(@topic, "update", :create)

    AppWeb.Endpoint.broadcast(
      @stats_topic,
      "item",
      {:create, payload: %{person_id: person_id}}
    )

    {:noreply, assign(socket, text_value: "", selected_tags: [])}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    person_id = get_person_id(socket.assigns)

    # Toggle the status of the item between 3 (:active) and 4 (:done)
    status = if Map.has_key?(data, "value"), do: 4, else: 3

    # need to restrict getting items to the people who own or have rights to access them!
    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{status: status, person_id: person_id})
    Timer.stop_timer_for_item_id(item.id)

    AppWeb.Endpoint.broadcast(@topic, "update", :toggle)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_tag", value, socket) do
    person_id = get_person_id(socket.assigns)
    selected_tags = socket.assigns.selected_tags
    tag = Tag.get_tag!(value["tag_id"])
    tags = Tag.list_person_tags(person_id)

    selected_tags =
      if Enum.member?(selected_tags, tag) do
        List.delete(selected_tags, tag)
      else
        [tag | selected_tags]
      end
      |> Enum.sort_by(& &1.text)

    {:noreply, assign(socket, tags: tags, selected_tags: selected_tags)}
  end

  @impl true
  def handle_event("filter-tags", %{"key" => _key, "value" => value}, socket) do
    person_id = get_person_id(socket.assigns)

    tags =
      Tag.list_person_tags(person_id)
      |> Enum.filter(fn t ->
        String.contains?(String.downcase(t.text), String.downcase(value))
      end)

    {:noreply, assign(socket, tags: tags)}
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

    AppWeb.Endpoint.broadcast(@topic, "update", {:start, item.id})

    AppWeb.Endpoint.broadcast(
      @stats_topic,
      "timer",
      {:create, payload: %{person_id: person_id}}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", data, socket) do
    timer_id = Map.get(data, "timerid")
    {:ok, _timer} = Timer.stop(%{id: timer_id})

    AppWeb.Endpoint.broadcast(@topic, "update", {:stop, Map.get(data, "id")})
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit-item", data, socket) do
    item_id = String.to_integer(data["id"])

    timers_list_changeset = Timer.list_timers_changesets(item_id)

    {:noreply,
     assign(socket, editing: item_id, editing_timers: timers_list_changeset)}
  end

  @impl true
  def handle_event(
        "update-item",
        %{"id" => item_id, "text" => text},
        socket
      ) do
    person_id = get_person_id(socket.assigns)
    current_item = Item.get_item!(item_id)

    Item.update_item(current_item, %{
      text: text,
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
    # Fetching the list of timer changesets to update
    timer_changeset_list = socket.assigns.editing_timers
    index = String.to_integer(index)

    timer = %{
      id: id,
      start: timer_start,
      stop: timer_stop
    }

    # Update the timer object we've created inside the changeset list
    case Timer.update_timer_inside_changeset_list(
           timer,
           index,
           timer_changeset_list,
           socket.assigns.hours_offset_fromUTC
         ) do
      {:ok, _list} ->
        # Updates item list and broadcast to other users
        AppWeb.Endpoint.broadcast(@topic, "update", :update)
        {:noreply, assign(socket, editing: nil, editing_timers: [])}

      {:error, updated_errored_list} ->
        {:noreply, assign(socket, editing_timers: updated_errored_list)}
    end
  end

  @impl true
  def handle_info(%Broadcast{event: "update", payload: payload}, socket) do
    person_id = get_person_id(socket.assigns)
    items = Item.items_with_timers(person_id)

    isEditingItem = socket.assigns.editing

    # If the item is being edited, we update the timer list of the item being edited.
    if isEditingItem do
      case payload do
        {:start, item_id} ->
          timers_list_changeset = Timer.list_timers_changesets(item_id)

          {:noreply,
           assign(socket,
             items: items,
             editing: item_id,
             editing_timers: timers_list_changeset
           )}

        {:stop, item_id} ->
          timers_list_changeset = Timer.list_timers_changesets(item_id)

          {:noreply,
           assign(socket,
             items: items,
             editing: item_id,
             editing_timers: timers_list_changeset
           )}

        _ ->
          {:noreply, assign(socket, items: items)}
      end

      # If not, just update the item list.
    else
      {:noreply, assign(socket, items: items)}
    end
  end

  @impl true
  def handle_info(
        %Broadcast{topic: @stats_topic, event: _event, payload: _payload},
        socket
      ) do
    {:noreply, socket}
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
  the tag names are separated by commas

  ## Examples

    tags_to_string([%Tag{text: "Learn"}, %Tag{text: "Elixir"}])
    "Learn, Elixir"

  """
  def tags_to_string(tags), do: Enum.map_join(tags, ", ", & &1.text)
end
