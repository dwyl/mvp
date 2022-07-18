defmodule AppWeb.AppLive do
  use AppWeb, :live_view
  alias App.{Item, Timer}

  @topic "live"

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@topic)
    # IO.inspect(Item.items_with_timers(1))
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
      assign(socket, items: Item.items_with_timers(1), active: %Item{}, editing: nil)

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
  def handle_event("edit-item", data, socket) do
    {:noreply, assign(socket, editing: String.to_integer(data["id"]))}
  end

  @impl true
  def handle_event("update-item", %{"id" => item_id, "text" => text}, socket) do
    current_item = Item.get_item!(item_id)
    Item.update_item(current_item, %{text: text})
    socket = assign(socket, items: Item.items_with_timers(1), editing: nil)
    AppWeb.Endpoint.broadcast_from(self(), @topic, "update", socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: "start|stop", payload: %{items: items}},
        socket
      ) do
    {:noreply, assign(socket, items: items, editing: nil)}
  end

  @impl true
  def handle_info(%{event: "update", payload: %{items: items}}, socket) do
    {:noreply, assign(socket, items: items, editing: nil)}
  end

  @impl true
  def handle_info(%{event: "delete", payload: %{items: items}}, socket) do
    {:noreply, assign(socket, items: items, editing: nil)}
  end

  # Check for status 4 (:done)
  def done?(item), do: item.status_code == 4

  # Check if an item has an active timer
  def started?(item) do
    not is_nil(item.start) and is_nil(item.end)
  end

  # An item without an end should be counting
  def timer_stopped?(item) do
    not is_nil(item.end)
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

	def timer_text(start, stop) do
		diff = timestamp(stop) - timestamp(start)
		
    # seconds
		s = if diff > 1000 do 
			s = diff / 1000 |> round()
			s = if s > 60, do: Integer.mod(s, 60), else: s
			s = leftPad(s)
    else
      "00"
    end

		# minutes
		m = if diff > 60000 do
			m = diff / 60000 |> round()
			m = if m > 60, do: Integer.mod(m, 60), else: m
      m = leftPad(m)
    else
      "00"
    end

		# hours
		h = if diff > 3600000 do
			h = diff / 3600000 |> round()
			h = leftPad(h)
    else
      "00"
    end

		"#{h}:#{m}:#{s}"
	end

  
end
