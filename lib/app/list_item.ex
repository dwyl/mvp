defmodule App.ListItem do
  use Ecto.Schema
  # import Ecto.Changeset
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

  # @doc false
  # def changeset(list_item) do
  #   %ListItem{}
  #   |> cast(attrs.item, [:person_id])
  #   |> validate_required([:person_id])
  # end

  @doc """
  `add_list_item/3` adds an `item` to a `list`.

  ## Examples

      iex> create_list(%{text: "Personal Todo List"})
      {:ok, %List{}}

      iex> create_list(%{text: nil})
      {:error, %Ecto.Changeset{}}

  """
  def add_list_item(item, list, position) do
    %ListItem{
      item: item,
      list: list,
      position: position,
      person_id: item.person_id
    }
    # |> changeset()
    |> Repo.insert()
  end
end
