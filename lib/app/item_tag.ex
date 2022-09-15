defmodule App.ItemTag do
  use Ecto.Schema
  alias App.{Item, Tag}

  schema "items_tags" do
    belongs_to(:item, Item)
    belongs_to(:tag, Tag)

    timestamps()
  end
end
