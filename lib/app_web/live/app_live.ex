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
    Item.create_item(%{text: text, person_id: 1, status_id: 2})
    socket = assign(socket, items: Item.list_items(), active: %Item{})
    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    # IO.inspect(data)
    status = if Map.has_key?(data, "value"), do: 4, else: 3
    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{id: item.id, status: status})
    socket = assign(socket, items: Item.list_items(), active: %Item{})
    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", data, socket) do
    Item.delete(Map.get(data, "id"))
    socket = assign(socket, items: Item.list_items(), active: %Item{})
    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  def checked?(item) do
    not is_nil(item.status) and item.status == 4
  end

  def completed?(item) do
    # IO.inspect(item)
    if not is_nil(item.status) and item.status == 4, do: "line-through text-green", else: ""
  end

end
