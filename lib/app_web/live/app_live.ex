defmodule AppWeb.AppLive do
  use AppWeb, :live_view
  alias App.{Item, Timer}

  @topic "live"

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@topic)

    {:ok,
     assign(socket, items: Item.list_items(), editing: nil, timer: %Timer{})}
  end

  @impl true
  def handle_event("create", %{"text" => text}, socket) do
    Item.create_item(%{text: text, person_id: 1, status_code: 2})

    socket =
      assign(socket, items: Item.list_items(), active: %Item{}, timer: %Timer{})

    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    status = if Map.has_key?(data, "value"), do: 4, else: 3

    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{status_code: status})

    socket =
      assign(socket, items: Item.list_items(), active: %Item{}, timer: %Timer{})

    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => item_id}, socket) do
    Item.delete_item(item_id)

    socket =
      assign(socket, items: Item.list_items(), active: %Item{}, timer: %Timer{})

    AppWeb.Endpoint.broadcast_from(self(), @topic, "delete", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("start", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    # status = if Map.has_key?(data, "value"), do: 4, else: 3
    item = Item.get_item!(Map.get(data, "id"))
    # Item.update_item(item, %{id: item.id, status_code: status})
    {:ok, timer} =
      Timer.start(%{
        item_id: item.id,
        person_id: 1,
        start: NaiveDateTime.utc_now()
      })

    socket =
      assign(socket, items: Item.list_items(), active: %Item{}, timer: timer)

    AppWeb.Endpoint.broadcast_from(self(), @topic, "start|stop", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    # status = if Map.has_key?(data, "value"), do: 4, else: 3
    # item = Item.get_item!(Map.get(data, "id"))
    # IO.inspect(data, label: "data")
    timer_id = Map.get(data, "timerid")
    # IO.inspect(timer_id, label: "timer_id")
    # Item.update_item(item, %{id: item.id, status_code: status})
    {:ok, _timer} = Timer.stop(%{id: timer_id})
    # IO.inspect(timer)

    socket =
      assign(socket, items: Item.list_items(), active: %Item{}, timer: %Timer{})

    AppWeb.Endpoint.broadcast_from(self(), @topic, "start|stop", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: "start|stop", payload: %{items: items, timer: timer}},
        socket
      ) do
    {:noreply, assign(socket, items: items, timer: timer)}
  end

  @impl true
  def handle_info(%{event: "update", payload: %{items: items, timer: timer}}, socket) do
    {:noreply, assign(socket, items: items, timer: timer)}
  end

  @impl true
  def handle_info(%{event: "delete", payload: %{items: items, timer: timer}}, socket) do
    {:noreply, assign(socket, items: items, timer: timer)}
  end

  # helper function that checks for status 4 (:done)
  def done?(item), do: item.status_code == 4

  def started?(item, timer) do
    # IO.inspect(item, label: "item")
    # IO.inspect(timer, label: "timer")
    item.id == timer.item_id
  end

  # def timestamp(timer) do
  #   timer.start |> DateTime.from_naive("Etc/UTC") |> DateTime.to_unix() |> IO.inspect()
  # end
end
