defmodule App.ItemList do
  use Ecto.Schema
  alias App.{Item, List}

  @primary_key false
  schema "items_lists" do
    belongs_to(:item, Item)
    belongs_to(:list, List)

    timestamps()
  end
end
