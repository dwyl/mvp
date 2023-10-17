defmodule AppWeb.TagsLive do
  use AppWeb, :live_view
  alias App.{DateTimeHelper, Person, Tag}

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

  def format_date(date) do
    DateTimeHelper.format_date(date)
  end
end
