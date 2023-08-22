defmodule App.ListItems do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.{Repo}
  alias __MODULE__

  schema "list_items" do
    field :list_id, :id
    field :person_id, :integer
    field :seq, :string

    timestamps()
  end

  @doc false
  def changeset(list_items, attrs) do
    list_items
    |> cast(attrs, [:list_id, :person_id, :seq])
    |> validate_required([:list_id, :person_id, :seq])
  end

  @doc """
  `get_list_items/2` retrieves the *latest* `list_items` record for a given `list_id`.
  """
  def get_list_items(list_id) do
    # IO.inspect("get_list_items(list_id: #{list_id})")

    sql = """
    SELECT li.seq
    FROM list_items li
    WHERE li.list_id = $1
    ORDER BY li.inserted_at DESC
    LIMIT 1
    """

    result = Ecto.Adapters.SQL.query!(Repo, sql, [list_id])
    # dbg(result.rows)
    if is_nil(result.rows) or result.rows == [] do
      []
    else
      result.rows |> List.first() |> List.first() |> String.split(",")
    end

    #
  end

  @doc """
  `add_list_item/3` adds an `item` to a `list` for the given `person_id`.
  """
  def add_list_item(item_id, list_id, person_id) do
    # Get latest list_items.seq for this list.id and person_id combo.
    prev_seq = get_list_items(list_id)
    # Add the `item.id` to the sequence
    seq = [item_id | prev_seq] |> Enum.join(",")

    %ListItems{}
    |> changeset(%{
      list_id: list_id,
      person_id: person_id,
      seq: seq
    })
    |> Repo.insert()
  end

  @doc """
  `add_all_items_to_all_list_for_person_id/1` does *exactly* what its' name suggests.
  Adds *all* the person's `items` to the `list_items.seq`.
  """
  def add_all_items_to_all_list_for_person_id(person_id) do
    all_list = App.List.get_list_by_name!("all", person_id)
    # IO.inspect("add_all_items_to_all_list_for_person_id(person_id: #{person_id})")
    all_items = App.Item.all_items_for_person(person_id)
    # The previous sequence of items if there is any:
    prev_seq = get_list_items(all_list.id)
    # Add add each `item.id` to the sequence of item ids:
    seq =
      Enum.reduce(all_items, prev_seq, fn i, acc ->
        [i.id | acc]
      end)
      |> Enum.join(",")

    %ListItems{}
    |> changeset(%{
      list_id: all_list.id,
      person_id: person_id,
      seq: seq
    })
    |> Repo.insert()
  end


#   @doc """
#   `move_item/3` updates the position of the `item` in a `list`.
#   This is used for drag and drop.
#   The `item_id` is the `item.id` for the `item` being repositioned e.g: "42"
#   and `item_ids_str` is the String of ids currently visible in the interface.
#   e.g: "1 2 3 42 71 93". so we can easily determine the precise position of the item_id.
#   """
#   def move_item(item_id, item_ids_str, list_id \\ 0) do
#     IO.inspect(
#       "move_item/3 -> item_id: #{item_id} | typeof item_id #{Useful.typeof(item_id)}"
#     )

#     item = App.Item.get_item!(item_id)
#     item_ids = String.split(item_ids_str, " ")

#     IO.inspect(
#       "item_ids_str: #{item_ids_str} | length(item_ids): #{length(item_ids)} "
#     )

#     # Get index of item_id in the item_ids list:
#     index = Enum.find_index(item_ids, &(&1 == "#{item_id}"))
#     IO.inspect("index: #{index}")

#     # Get the list by the list_id or text "all":
#     list =
#       if list_id == 0 do
#         # For now we only have the "all" list, but soon we will have "PARA" 😉
#         App.List.get_list_by_text!(item.person_id, "all")
#       else
#         App.List.get_list!(list_id)
#       end

#     # Derive the New Position
#     # Moved somewhere else in the list including the Bottom:
#     new_pos =
#       if index == 0 do
#         # Moved to Top of List:
#         # Find the *Next* item_id in the list:
#         next_id = Enum.at(item_ids, index + 1)
#         # Get the position of the *Next* item:
#         next_pos = get_list_item_position(next_id, list.id)

#         next_pos
#         |> Decimal.from_float()
#         |> Decimal.sub("0.000001")
#         |> Decimal.round(6)
#         |> Decimal.to_float()
#       else
#         # Find the *Previous* item_id in the list:
#         prev_id = Enum.at(item_ids, index - 1)
#         prev_pos = get_list_item_position(prev_id, list.id)

#         prev_pos
#         |> Decimal.from_float()
#         |> Decimal.add("0.000001")
#         |> Decimal.round(6)
#         |> Decimal.to_float()
#       end

#     add_list_item(item, list, item.person_id, new_pos)
#   end
end
