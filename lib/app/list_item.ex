defmodule App.ListItem do
  use Ecto.Schema
  alias App.{Item, List}

  @primary_key false
  schema "lists_items" do
    belongs_to(:item, Item)
    belongs_to(:list, List)

    timestamps()
  end
end
