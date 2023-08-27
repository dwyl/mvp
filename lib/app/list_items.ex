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
  `create_list_items_seq/3` inserts a new `list_items` record
  where the the `list_items.seq` is the latest sequence of `item ids`.
  This is used when reordering using drag and drop in the frontend interface.
  and `seq` is the String of ids currently visible in the interface.
  e.g: "1,2,3,42,71,93". so we can easily determine the precise position of an `item_id`.
  """
  def create_list_items_seq(list_id, person_id, seq) do
    # IO.inspect("create_list_itemix ms_seq(list_id: #{list_id}, person_id: #{person_id}, seq: #{seq})")
    %ListItems{}
    |> changeset(%{
      list_id: list_id,
      person_id: person_id,
      seq: seq
    })
    |> Repo.insert()
  end

  def list_items_seq_sql do
    """
    SELECT li.seq
    FROM list_items li
    WHERE li.list_id = $1
    ORDER BY li.inserted_at DESC
    LIMIT 1
    """
  end

  @doc """
  `get_list_items/2` retrieves the *latest* `list_items` record for a given `list_id`.
  """
  def get_list_items(list_id) do
    # IO.inspect("get_list_items(list_id: #{list_id})")

    sql = list_items_seq_sql()

    result = Ecto.Adapters.SQL.query!(Repo, sql, [list_id])
    # dbg(result.rows)
    if is_nil(result.rows) or result.rows == [] do
      []
    else
      result.rows |> List.first() |> List.first() |> String.split(",")
    end
  end

  @doc """
  `add_list_item/3` adds an `item` to a `list` for the given `person_id`.
  """
  def add_list_item(item_id, list_id, person_id) do
    # Get latest list_items.seq for this list.id and person_id combo.
    prev_seq = get_list_items(list_id)
    # Add the `item.id` to the sequence
    seq = [item_id | prev_seq] |> Enum.join(",")
    create_list_items_seq(list_id, person_id, seq)
  end

  @doc """
  `add_all_items_to_all_list_for_person_id/1` does *exactly* what its' name suggests.
  Adds *all* the person's `items` to the `list_items.seq`.
  """
  def add_all_items_to_all_list_for_person_id(person_id) do
    all_list = App.List.get_all_list_for_person(person_id)
    all_items = App.Item.all_items_for_person(person_id)
    # The previous sequence of items if there is any:
    prev_seq = get_list_items(all_list.id)
    # Add add each `item.id` to the sequence of item ids:
    seq =
      Enum.reduce(all_items, prev_seq, fn i, acc ->
        [i.id | acc]
      end)
      |> Enum.join(",")

    create_list_items_seq(all_list.id, person_id, seq)
  end
end
