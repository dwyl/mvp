defmodule App.ListItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.{Repo}
  alias __MODULE__

  schema "list_items" do
    belongs_to :item, App.Item
    belongs_to :list, App.List
    # field :item_id, :id
    # field :list_id, :id
    field :person_id, :integer
    field :position, :float

    timestamps()
  end

  @doc false
  def changeset(list_item) do
    list_item
    |> cast(Map.from_struct(list_item), [:person_id, :position])
    |> validate_required([:person_id])
  end

  @doc """
  `add_list_item/4` adds an `item` to a `list` for the given `person_id`.
  """
  def add_list_item(item, list, person_id, position) do
    %ListItem{
      item: item,
      list: list,
      person_id: person_id,
      position: position
    }
    |> changeset()
    |> Repo.insert()
  end

  @doc """
  `add_item_to_all_list/1` adds the `item` the "all" `list` for `person_id`.
  """
  def add_item_to_all_list(item) do
    all_list = App.List.get_list_by_text!(item.person_id, "all")

    %ListItem{
      item: item,
      list: all_list,
      person_id: item.person_id,
      position: next_position_on_list(all_list.id)
    }
    |> changeset()
    |> Repo.insert()
  end

  @doc """
  `next_position_on_list/1` retrieves the next position on the given `list`.
  """
  def next_position_on_list(list_id) do
    sql = """
    SELECT COUNT(DISTINCT li.item_id)
    FROM list_items li
    JOIN items i on i.id = li.item_id
    WHERE li.list_id = $1
    AND li.position != 999999.999
    AND i.status != 4
    """

    result = Ecto.Adapters.SQL.query!(Repo, sql, [list_id])
    # Grab the first result, increment by 1 and divide by 1 to make a Float:
    count = List.flatten(result.rows) |> List.first()
    (count + 1) / 1
  end

  @doc """
  `remove_list_item/3` "removes" an `item` from a `list`
  by inserting a record where the position=999999.999
  Given that `list_items` is an append-only to preserve history,
  we need a way of ignoring an item that should no longer be on a list.
  If you have a better suggestion, please share: github.com/dwyl/mvp/issues/356
  """
  def remove_list_item(item, list, person_id) do
    %ListItem{
      item: item,
      list: list,
      person_id: person_id,
      position: 999_999.999
    }
    |> changeset()
    |> Repo.insert()
  end

  @doc """
  `get_list_item_position/2` retrieves the position for an item in the given list.
  """
  def get_list_item_position(item_id, list_id) do
    # IO.inspect("get_list_item_position | item_id: #{item_id} #{Useful.typeof(item_id)} | list_id: #{list_id} #{Useful.typeof(list_id)}")
    item_id =
      if Useful.typeof(item_id) == "binary" do
        {int, _} = Integer.parse(item_id)
        int
      else
        item_id
      end

    sql = """
    SELECT li.position
    FROM list_items li
    WHERE li.item_id = $1
    AND li.list_id = $2
    ORDER BY li.inserted_at DESC
    LIMIT 1
    """

    result = Ecto.Adapters.SQL.query!(Repo, sql, [item_id, list_id])
    # dbg(result)
    result.rows |> List.first() |> List.first()
  end

  @doc """
  `move_item/3` updates the position of the `item` in a `list`.
  This is used for drag and drop.
  The `item_id` is the `item.id` for the `item` being repositioned e.g: "42"
  and `item_ids_str` is the String of ids currently visible in the interface.
  e.g: "1 2 3 42 71 93". so we can easily determine the precise position of the item_id.
  """
  def move_item(item_id, item_ids_str, list_id \\ 0) do
    IO.inspect(
      "move_item/3 -> item_id: #{item_id} | typeof item_id #{Useful.typeof(item_id)}"
    )

    item = App.Item.get_item!(item_id)
    item_ids = String.split(item_ids_str, " ")

    IO.inspect(
      "item_ids_str: #{item_ids_str} | length(item_ids): #{length(item_ids)} "
    )

    # Get index of item_id in the item_ids list:
    index = Enum.find_index(item_ids, &(&1 == "#{item_id}"))
    IO.inspect("index: #{index}")

    # Get the list by the list_id or text "all":
    list =
      if list_id == 0 do
        # For now we only have the "all" list, but soon we will have "PARA" 😉
        App.List.get_list_by_text!(item.person_id, "all")
      else
        App.List.get_list!(list_id)
      end

    # Derive the New Position
    # Moved somewhere else in the list including the Bottom:
    new_pos =
      if index == 0 do
        # Moved to Top of List:
        # Find the *Next* item_id in the list:
        next_id = Enum.at(item_ids, index + 1)
        # Get the position of the *Next* item:
        next_pos = get_list_item_position(next_id, list.id)

        next_pos
        |> Decimal.from_float()
        |> Decimal.sub("0.000001")
        |> Decimal.round(6)
        |> Decimal.to_float()
      else
        # Find the *Previous* item_id in the list:
        prev_id = Enum.at(item_ids, index - 1)
        prev_pos = get_list_item_position(prev_id, list.id)

        prev_pos
        |> Decimal.from_float()
        |> Decimal.add("0.000001")
        |> Decimal.round(6)
        |> Decimal.to_float()
      end

    add_list_item(item, list, item.person_id, new_pos)
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  # Below this point is Lists transition code that will be DELETED! #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

  @doc """
  `get_items_on_all_list/1` retrieves a List of item.ids e.g: [8, 6, 4, 2]
  that are on the "all" list for a given `person_id`.
  This is relevant as we transition to having Lists.
  But once all data is migrated we can delete this function and it's sister below.
  """
  def get_items_on_all_list(person_id) do
    # Retrieve list of `items` for the `person_id` on the "all" list:
    sql = """
    SELECT li.item_id
    FROM list_items li
    JOIN lists l ON li.list_id = l.id
    WHERE li.person_id = $1
    AND l.text = 'all'
    GROUP by li.item_id, li.list_id, l.text
    """

    result = Ecto.Adapters.SQL.query!(Repo, sql, [person_id])
    List.flatten(result.rows)
  end

  @doc """
  `add_items_to_all_list/1` adds all `items` to the "all" `list`.
  This is a temporary function to migrate existing data (`items`)
  to the new schema. Once we are certain that everyone using the MVP
  has their data migrated, we can delete this function.
  """
  def add_items_to_all_list(person_id) do
    all_list = App.List.get_list_by_text!(person_id, "all")
    all_items = App.Item.all_items_for_person(person_id)
    item_ids_in_all_list = get_items_on_all_list(person_id)

    all_items
    |> Enum.with_index()
    |> Enum.each(fn {item, index} ->
      unless Enum.member?(item_ids_in_all_list, item.id) do
        add_list_item(item, all_list, person_id, (index + 1) / 1)
      end
    end)
  end
end
