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
