defmodule AppWeb.TagsLive do
  use AppWeb, :live_view
  alias App.{DateTimeHelper, Person, Tag, Repo}

  # run authentication on mount
  on_mount(AppWeb.AuthController)

  @tags_topic "tags"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@tags_topic)

    person_id = Person.get_person_id(socket.assigns)

    tags = Tag.list_person_tags_complete(person_id)

    {:ok,
     assign(socket,
       tags: tags,
       lists: App.List.get_lists_for_person(person_id),
       custom_list: false,
       sort_column: :text,
       sort_order: :asc
     )}
  end

  @impl true
  def handle_event("sort", %{"key" => key}, socket) do
    sort_column =
      key
      |> String.to_atom()

    sort_order =
      if socket.assigns.sort_column == sort_column do
        Repo.toggle_sort_order(socket.assigns.sort_order)
      else
        :asc
      end

    person_id = Person.get_person_id(socket.assigns)

    tags = Tag.list_person_tags_complete(person_id, sort_column, sort_order)

    {:noreply,
     assign(socket,
       tags: tags,
       sort_column: sort_column,
       sort_order: sort_order
     )}
  end

  def format_date(date) do
    DateTimeHelper.format_date(date)
  end

  def format_seconds(seconds) do
    DateTimeHelper.format_duration(seconds)
  end
end
