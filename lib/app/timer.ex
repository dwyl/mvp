defmodule App.Timer do
  use Ecto.Schema
  import Ecto.Changeset
  # import Ecto.Query
  alias App.Repo
  alias __MODULE__

  schema "timers" do
    field :end, :naive_datetime
    field :start, :naive_datetime
    field :item_id, :id
    field :person_id, :id

    timestamps()
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [:item_id, :start, :end, :person_id])
    |> validate_required([:item_id, :start])
  end


  @doc """
  `start/1` starts a timer.

  ## Examples

      iex> start(%{item_id: 1, })
      {:ok, %Timer{}}

      iex> create_item(%{item_id: nil})
      {:error, %Ecto.Changeset{}}

  """
  def start(attrs \\ %{}) do
    %Timer{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
