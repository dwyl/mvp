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
  `add_list_item/4` adds an `item` to a `list`.
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
  `get_list_items/1` retrieves `list_items` in order for a given `list_id`.
  Should only return one row per item + list combo (i.e. GROUP BY)
  and should ignore items that have a position=999999.999
  """
  # def get_list_items(list_id) do
  #   sql = """
  #   SELECT i.person_id,
  #   COUNT(distinct i.id) AS "num_items",
  #   COUNT(distinct t.id) AS "num_timers"
  #   FROM items i
  #   LEFT JOIN timers t ON t.item_id = i.id
  #   GROUP BY i.person_id
  #   ORDER BY i.person_id
  #   """

  #   Ecto.Adapters.SQL.query!(Repo, sql)
  #   |> map_columns_to_values()
  # end


  # Below this point is Lists transition code that will be Deleted

  @doc """
  `get_items_on_all_list/1` retrieves a List of item.ids e.g: [8, 6, 4, 2]
  that are on the "All" list for a given `person_id`.
  This is relevant as we transition to having Lists.
  But once all data is migrated we can delete this function and it's sister below.
  """
  def get_items_on_all_list(person_id) do
    # Retrieve list of `items` for the `person_id` on the "All" list:
    sql = """
    SELECT li.item_id
    FROM list_items li
    JOIN lists l ON li.list_id = l.id
    WHERE li.person_id = $1
    AND l.text = 'All'
    GROUP by li.item_id, li.list_id, l.text
    """

    result = Ecto.Adapters.SQL.query!(Repo, sql, [person_id])
    List.flatten(result.rows)
  end

  @doc """
  `add_items_to_all_list/1` adds all `items` to the "All" `list`.
  This is a temporary function to migrate existing data (`items`)
  to the new schema. Once we are certain that everyone using the MVP
  has their data migrated, we can delete this function.
  """
  def add_items_to_all_list(person_id) do
    all_list = App.List.get_list_by_text!(person_id, "All")
    all_items = App.Item.all_items_for_person(person_id)
    item_ids_in_all_list = get_items_on_all_list(person_id)

    all_items
    |> Enum.with_index
    |> Enum.each(fn({item, index}) ->
      unless Enum.member?(item_ids_in_all_list , item.id) do
        # IO.inspect(item.id)
        add_list_item(item, all_list, person_id, (index + 1)/1)
      end
      # IO.puts("-------> #{index} => #{id} | #{person_id}")
    end)
  end

end
