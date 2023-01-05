defmodule AppWeb.StatsLive do
  require Logger
  use AppWeb, :live_view
  alias App.Item
  alias Phoenix.Socket.Broadcast

  # run authentication on mount
  on_mount(AppWeb.AuthController)

  @topic "live"


  @impl true
  def mount(_params, _session, socket) do

    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@topic)

    metrics = Item.person_with_item_and_timer_count()

    {:ok,
     assign(socket,
       metrics: metrics
     )}
  end

  def handle_info(%Broadcast{event: "update", payload: payload}, socket) do
    dbg("cuh")
    {:noreply, socket}
  end
end
