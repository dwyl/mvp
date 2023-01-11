defmodule AppWeb.StatsLive do
  require Logger
  use AppWeb, :live_view
  alias App.Item
  alias Phoenix.Socket.Broadcast

  # run authentication on mount
  on_mount(AppWeb.AuthController)

  @stats_topic "stats"

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@stats_topic)

    metrics = Item.person_with_item_and_timer_count()

    {:ok,
     assign(socket,
       metrics: metrics
     )}
  end

  @impl true
  def handle_info(
        %Broadcast{topic: @stats_topic, event: "item", payload: payload},
        socket
      ) do
    metrics = socket.assigns.metrics

    case payload do
      {:create, payload: payload} ->
        updated_metrics = Enum.map(metrics, fn row -> add_row(row, payload) end)

        {:noreply, assign(socket, metrics: updated_metrics)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        %Broadcast{topic: @stats_topic, event: "timer", payload: payload},
        socket
      ) do
    metrics = socket.assigns.metrics

    case payload do
      {:create, payload: payload} ->
        updated_metrics = Enum.map(metrics, fn row -> add_row(row, payload) end)

        {:noreply, assign(socket, metrics: updated_metrics)}

      _ ->
        {:noreply, socket}
    end
  end

  def add_row(row, payload) do
    row =
      if row.person_id == payload.person_id do
        Map.put(row, :num_timers, row.num_timers + 1)
      else
        row
      end

    row
  end

  def person_link(person_id) do
    "https://auth.dwyl.com/people/#{person_id}"
  end
end
