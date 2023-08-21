defmodule App.ListItems do
  use Ecto.Schema
  import Ecto.Changeset

  schema "list_items" do
    field :list_id, :id
    field :person_id, :integer
    field :seq, :string

    timestamps()
  end

  @doc false
  def changeset(list_items, attrs) do
    list_items
    |> cast(attrs, [:person_id, :seq])
    |> validate_required([:person_id, :seq])
  end


    @doc """
    `get_list_items/2` retrieves the *latest* `list_items` record for a given `list_id`.
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
  `add_list_item/3` adds an `item` to a `list` for the given `person_id`.
  """
  def add_list_item(item, list, person_id) do
    # Get latest list_items.seq for this list.id and person_id combo.


    # Add the `item.id` to the sequence
    seq = if list.sort == 1 do



    end

    %ListItem{
      item: item,
      list: list,
      person_id: person_id,
      position: position
    }
    |> changeset()
    |> Repo.insert()
  end


end
