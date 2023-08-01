defmodule AppWeb.StatsLive do
  require Logger
  use AppWeb, :live_view
  alias App.{Item, DateTimeHelper}
  alias Phoenix.Socket.Broadcast

  # run authentication on mount
  on_mount(AppWeb.AuthController)

  @stats_topic "stats"

  defp get_person_id(assigns), do: assigns[:person][:id] || 0

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@stats_topic)

    person_id = get_person_id(socket.assigns)
    metrics = Item.person_with_item_and_timer_count()

    {:ok,
     assign(socket,
       person_id: person_id,
       metrics: metrics,
       sort_column: :person_id,
       sort_order: :asc
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
        updated_metrics =
          Enum.map(metrics, fn row -> add_row(row, payload, :num_items) end)

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
        updated_metrics =
          Enum.map(metrics, fn row -> add_row(row, payload, :num_timers) end)

        {:noreply, assign(socket, metrics: updated_metrics)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("sort", %{"key" => key}, socket) do
    sort_column =
      key
      |> String.to_atom()

    sort_order =
      if socket.assigns.sort_column == sort_column do
        toggle_sort_order(socket.assigns.sort_order)
      else
        :asc
      end

    metrics = Item.person_with_item_and_timer_count(sort_column, sort_order)

    {:noreply,
     assign(socket,
       metrics: metrics,
       sort_column: sort_column,
       sort_order: sort_order
     )}
  end

  def add_row(row, payload, key) do
    row =
      if row.person_id == payload.person_id do
        Map.put(row, key, Map.get(row, key) + 1)
      else
        row
      end

    row
  end

  def person_link(person_id) do
    "https://auth.dwyl.com/people/#{person_id}"
  end

  def format_date(date) do
    DateTimeHelper.format_date(date)
  end

  def format_seconds(seconds) do
    DateTimeHelper.format_duration(seconds)
  end

  def is_highlighted_person?(metric, person_id),
    do: metric.person_id == person_id

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc
end
