defmodule App.Item do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias App.Repo
  alias __MODULE__

  schema "items" do
    field :text, :string
    field :status_code, :integer
    field :person_id, :integer
    
    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:text, :status_code, :person_id])
    |> validate_required([:text])
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{text: "Learn LiveView"})
      {:ok, %Item{}}

      iex> create_item(%{text: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs) do
    %Item{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Returns the list of items where the status is different to "deleted"

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Item
    |> order_by(desc: :inserted_at)
    |> where([i], is_nil(i.status_code) or i.status_code != 6)
    |> Repo.all()
  end

  # sadly, this is not built-in ...
  # ref: https://groups.google.com/g/elixir-ecto/c/0cubhSd3QS0/m/DLdQsFrcBAAJ
  defp map_columns_to_values(res) do
    Enum.map(res.rows, fn(row) ->
      Enum.zip(res.columns, row) 
      |> Map.new |> AtomicMap.convert()
    end)
  end

  @doc """
  `items_with_timers/1` Returns a List of items with the latest associated timers.
  
  ## Examples

  iex> items_with_timers()
  [
    %{text: "hello", person_id: 1, status_code: 2, start: 2022-07-14 09:35:18},
    %{text: "world", person_id: 2, status_code: 7, start: 2022-07-15 04:20:42}
  ]
  """
  # 
  def items_with_timers(person_id \\ 1) do
    sql = """
    SELECT DISTINCT ON (i.id)
      i.id, i.text, i.status_code, i.person_id, t.start, t.end 
      FROM items i
    FULL JOIN timers as t ON t.item_id = i.id
    WHERE i.person_id = $1
      AND i.status_code IS NOT NULL AND i.status_code != 6
    ORDER BY i.id DESC, t.start DESC;
    """

    Ecto.Adapters.SQL.query!(Repo, sql, [person_id])
    |> map_columns_to_values()
  end


  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(id) do
    get_item!(id)
    |> Item.changeset(%{status_code: 6})
    |> Repo.update()
  end
end
