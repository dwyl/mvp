defmodule AppWeb.AppLive do
  use AppWeb, :live_view
  alias App.{Item, Timer}
  # run authentication on mount
  on_mount AppWeb.AuthController

  @topic "live"

  defp get_person_id(assigns) do
    if Map.has_key?(assigns, :person) do
      assigns.person.id
    else
      0
    end
  end

  # assign default values to socket:
  defp assign_socket(socket) do
    person_id = get_person_id(socket.assigns)
    assign(socket, items: Item.items_with_timers(person_id), active: %Item{}, editing: nil)
  end

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@topic)
    {:ok, assign_socket(socket)}
  end

  @impl true
  def handle_event("create", %{"text" => text}, socket) do
    person_id = get_person_id(socket.assigns)
    Item.create_item(%{text: text, person_id: person_id, status_code: 2})
    # IO.inspect(socket.assigns, label: "handle_event create socket.assigns")
    socket = assign_socket(socket)

    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    status = if Map.has_key?(data, "value"), do: 4, else: 3

    # need to restrict getting items to the people who own or have rights to access them!
    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{status_code: status})
    Timer.stop_timer_for_item_id(item.id)
    socket = assign_socket(socket)
    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => item_id}, socket) do
    Item.delete_item(item_id)
    socket = assign_socket(socket)
    AppWeb.Endpoint.broadcast_from(self(), @topic, "delete", socket.assigns)
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

    socket = assign_socket(socket)

    AppWeb.Endpoint.broadcast_from(self(), @topic, "start|stop", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", data, socket) do
    timer_id = Map.get(data, "timerid")
    {:ok, _timer} = Timer.stop(%{id: timer_id})
    socket = assign_socket(socket)

    AppWeb.Endpoint.broadcast_from(self(), @topic, "start|stop", socket.assigns)
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
    socket = assign_socket(socket)
    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: "start|stop", payload: %{items: _items}},
        socket
      ) do
    {:noreply, assign_socket(socket)}
  end

  @impl true
  def handle_info(%{event: "update", payload: %{items: _items}}, socket) do
    {:noreply, assign_socket(socket)}
  end

  @impl true
  def handle_info(%{event: "delete", payload: %{items: _items}}, socket) do
    {:noreply, assign_socket(socket)}
  end

  # Check for status 4 (:done)
  def done?(item), do: item.status_code == 4

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
  def leftPad(val) do
    if val < 10, do: "0#{to_string(val)}", else: val
  end

  def timer_text(item) do
    if is_nil(item) or is_nil(item.start) or is_nil(item.stop) do
      ""
    else
      diff = timestamp(item.stop) - timestamp(item.start)

      # seconds
      s = if diff > 1000 do
        s = diff / 1000 |> trunc()
        s = if s > 60, do: Integer.mod(s, 60), else: s
        leftPad(s)
      else
      "00"
      end

      # minutes
      m = if diff > 60000 do
        m = diff / 60000 |> trunc()
        m = if m > 60, do: Integer.mod(m, 60), else: m
        leftPad(m)
      else
        "00"
      end

      # hours
      h = if diff > 3600000 do
        h = diff / 3600000 |> trunc()
        leftPad(h)
      else
        "00"
      end

      "#{h}:#{m}:#{s}"
    end
  end
end
