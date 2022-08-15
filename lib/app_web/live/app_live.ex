defmodule AppWeb.AppLive do
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
    {:ok, assign(socket, items: items, editing: nil, filter: "active")}
  end

  @impl true
  def handle_event("create", %{"text" => text}, socket) do
    person_id = get_person_id(socket.assigns)
    Item.create_item(%{text: text, person_id: person_id, status: 2})

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
    {:noreply, assign(socket, editing: String.to_integer(data["id"]))}
  end

  @impl true
  def handle_event("update-item", %{"id" => item_id, "text" => text}, socket) do
    current_item = Item.get_item!(item_id)
    Item.update_item(current_item, %{text: text})

    AppWeb.Endpoint.broadcast(@topic, "update", :update)
    {:noreply, assign(socket, editing: nil)}
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

    {:noreply, assign(socket, filter: filter)}
  end

  defp filter_items(items, filter) do
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
end
