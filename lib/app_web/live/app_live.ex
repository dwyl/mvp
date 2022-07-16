defmodule AppWeb.AppLive do
  use AppWeb, :live_view
  alias App.{Item, Timer}

  @topic "live"

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@topic)

    {:ok,
     assign(socket, items: Item.items_with_timers(1), editing: nil)}
  end

  @impl true
  def handle_event("create", %{"text" => text}, socket) do
    Item.create_item(%{text: text, person_id: 1, status_code: 2})

    socket =
      assign(socket, items: Item.items_with_timers(1), active: %Item{})

    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    status = if Map.has_key?(data, "value"), do: 4, else: 3

    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{status_code: status})
    # IO.inspect(Item.items_with_timers(1), label: "Item.items_with_timers(1)")
    socket =
      assign(socket, items: Item.items_with_timers(1), active: %Item{})

    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => item_id}, socket) do
    Item.delete_item(item_id)

    socket =
      assign(socket, items: Item.items_with_timers(1), active: %Item{})

    AppWeb.Endpoint.broadcast_from(self(), @topic, "delete", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("start", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    # status = if Map.has_key?(data, "value"), do: 4, else: 3
    item = Item.get_item!(Map.get(data, "id"))
    # Item.update_item(item, %{id: item.id, status_code: status})
    {:ok, _timer} =
      Timer.start(%{
        item_id: item.id,
        person_id: 1,
        start: NaiveDateTime.utc_now()
      })

    socket =
      assign(socket, items: Item.items_with_timers(1), active: %Item{})

    AppWeb.Endpoint.broadcast_from(self(), @topic, "start|stop", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    timer_id = Map.get(data, "timerid")
    {:ok, _timer} = Timer.stop(%{id: timer_id})

    socket =
      assign(socket, items: Item.items_with_timers(1), active: %Item{})

    AppWeb.Endpoint.broadcast_from(self(), @topic, "start|stop", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: "start|stop", payload: %{items: items}},
        socket
      ) do
    {:noreply, assign(socket, items: items)}
  end

  @impl true
  def handle_info(%{event: "update", payload: %{items: items}}, socket) do
    {:noreply, assign(socket, items: items)}
  end

  @impl true
  def handle_info(%{event: "delete", payload: %{items: items}}, socket) do
    {:noreply, assign(socket, items: items)}
  end

  # Check for status 4 (:done)
  def done?(item), do: item.status_code == 4

  # Check if an item has an active timer
  def started?(item) do
    not is_nil(item.start) and is_nil(item.end)
  end

  # Convert Elixir NaiveDateTime to JS (Unix) Timestamp
  def timestamp(naive_datetime) do
    DateTime.from_naive!(naive_datetime, "Etc/UTC")
    |> DateTime.to_unix(:millisecond)
  end
end
