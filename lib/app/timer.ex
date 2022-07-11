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
  `get_timer/1` gets a single Timer.

  Raises `Ecto.NoResultsError` if the Timer does not exist.

  ## Examples

      iex> get_timer!(123)
      %Timer{}
  """
  def get_timer!(id), do: Repo.get!(Timer, id)


  @doc """
  `start/1` starts a timer.

  ## Examples

      iex> start(%{item_id: 1, })
      {:ok, %Timer{start: ~N[2022-07-11 04:20:42]}}

  """
  def start(attrs \\ %{}) do
    %Timer{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  `stop/1` stops a timer.

  ## Examples

      iex> stop(%{id: 1})
      {:ok, %Timer{end: ~N[2022-07-11 05:15:31], etc.}}

  """
  def stop(attrs \\ %{}) do
    get_timer!(attrs.id)
    |> changeset(%{end: NaiveDateTime.utc_now})
    |> Repo.update()
  end
end
