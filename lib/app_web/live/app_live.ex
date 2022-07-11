defmodule AppWeb.AppLive do
  use AppWeb, :live_view
  alias App.Item

  @topic "live"

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, items: Item.list_items(), editing: nil)}
  end

  @impl true
  def handle_event("create", %{"text" => text}, socket) do
    Item.create_item(%{text: text, person_id: 1, status_code: 2})
    socket = assign(socket, items: Item.list_items(), active: %Item{})
    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    status = if Map.has_key?(data, "value"), do: 4, else: 3
    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{id: item.id, status_code: status})
    socket = assign(socket, items: Item.list_items(), active: %Item{})
    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", data, socket) do
    Item.delete_item(Map.get(data, "id"))
    socket = assign(socket, items: Item.list_items(), active: %Item{})
    AppWeb.Endpoint.broadcast_from(self(), @topic, "delete", socket.assigns)
    {:noreply, socket}
  end

  # helper function that checks for status 4 (:done)
  def done?(item) do
    not is_nil(item.status_code) and item.status_code == 4
  end
end
