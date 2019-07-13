defmodule App.Ctx do
  @moduledoc """
  The Ctx context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Ctx.Kind

  @doc """
  Returns the list of kinds.

  ## Examples

      iex> list_kinds()
      [%Kind{}, ...]

  """
  def list_kinds do
    Repo.all(Kind)
  end

  @doc """
  Gets a single kind.

  Raises `Ecto.NoResultsError` if the Kind does not exist.

  ## Examples

      iex> get_kind!(123)
      %Kind{}

      iex> get_kind!(456)
      ** (Ecto.NoResultsError)

  """
  def get_kind!(id), do: Repo.get!(Kind, id)

  @doc """
  Creates a kind.

  ## Examples

      iex> create_kind(%{field: value})
      {:ok, %Kind{}}

      iex> create_kind(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_kind(attrs \\ %{}) do
    %Kind{}
    |> Kind.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a kind.

  ## Examples

      iex> update_kind(kind, %{field: new_value})
      {:ok, %Kind{}}

      iex> update_kind(kind, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_kind(%Kind{} = kind, attrs) do
    kind
    |> Kind.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Kind.

  ## Examples

      iex> delete_kind(kind)
      {:ok, %Kind{}}

      iex> delete_kind(kind)
      {:error, %Ecto.Changeset{}}

  """
  def delete_kind(%Kind{} = kind) do
    Repo.delete(kind)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking kind changes.

  ## Examples

      iex> change_kind(kind)
      %Ecto.Changeset{source: %Kind{}}

  """
  def change_kind(%Kind{} = kind) do
    Kind.changeset(kind, %{})
  end

  alias App.Ctx.Status

  @doc """
  Returns the list of status.

  ## Examples

      iex> list_status()
      [%Status{}, ...]

  """
  def list_status do
    Repo.all(Status)
  end

  @doc """
  Gets a single status.

  Raises `Ecto.NoResultsError` if the Status does not exist.

  ## Examples

      iex> get_status!(123)
      %Status{}

      iex> get_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_status!(id), do: Repo.get!(Status, id)

  @doc """
  Creates a status.

  ## Examples

      iex> create_status(%{field: value})
      {:ok, %Status{}}

      iex> create_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_status(attrs \\ %{}) do
    %Status{}
    |> Status.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a status.

  ## Examples

      iex> update_status(status, %{field: new_value})
      {:ok, %Status{}}

      iex> update_status(status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_status(%Status{} = status, attrs) do
    status
    |> Status.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Status.

  ## Examples

      iex> delete_status(status)
      {:ok, %Status{}}

      iex> delete_status(status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_status(%Status{} = status) do
    Repo.delete(status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking status changes.

  ## Examples

      iex> change_status(status)
      %Ecto.Changeset{source: %Status{}}

  """
  def change_status(%Status{} = status) do
    Status.changeset(status, %{})
  end

  alias App.Ctx.Human

  @doc """
  Returns the list of humans.

  ## Examples

      iex> list_humans()
      [%Human{}, ...]

  """
  def list_humans do
    Repo.all(Human)
  end

  @doc """
  Gets a single human.

  Raises `Ecto.NoResultsError` if the Human does not exist.

  ## Examples

      iex> get_human!(123)
      %Human{}

      iex> get_human!(456)
      ** (Ecto.NoResultsError)

  """
  def get_human!(id), do: Repo.get!(Human, id)

  @doc """
  Creates a human.

  ## Examples

      iex> create_human(%{field: value})
      {:ok, %Human{}}

      iex> create_human(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_human(attrs \\ %{}) do
    %Human{}
    |> Human.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a human.

  ## Examples

      iex> update_human(human, %{field: new_value})
      {:ok, %Human{}}

      iex> update_human(human, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_human(%Human{} = human, attrs) do
    human
    |> Human.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Human.

  ## Examples

      iex> delete_human(human)
      {:ok, %Human{}}

      iex> delete_human(human)
      {:error, %Ecto.Changeset{}}

  """
  def delete_human(%Human{} = human) do
    Repo.delete(human)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking human changes.

  ## Examples

      iex> change_human(human)
      %Ecto.Changeset{source: %Human{}}

  """
  def change_human(%Human{} = human) do
    Human.changeset(human, %{})
  end

  alias App.Ctx.Item

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
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
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
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

  @doc """
  Deletes a Item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{source: %Item{}}

  """
  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end

  alias App.Ctx.List

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists()
      [%List{}, ...]

  """
  def list_lists do
    Repo.all(List)
  end

  @doc """
  Gets a single list.

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!(123)
      %List{}

      iex> get_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list!(id), do: Repo.get!(List, id)

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(%{field: value})
      {:ok, %List{}}

      iex> create_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(attrs \\ %{}) do
    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a List.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{source: %List{}}

  """
  def change_list(%List{} = list) do
    List.changeset(list, %{})
  end

  alias App.Ctx.Timer

  @doc """
  Returns the list of timers.

  ## Examples

      iex> list_timers()
      [%Timer{}, ...]

  """
  def list_timers do
    Repo.all(Timer)
  end

  @doc """
  Gets a single timer.

  Raises `Ecto.NoResultsError` if the Timer does not exist.

  ## Examples

      iex> get_timer!(123)
      %Timer{}

      iex> get_timer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timer!(id), do: Repo.get!(Timer, id)

  @doc """
  Creates a timer.

  ## Examples

      iex> create_timer(%{field: value})
      {:ok, %Timer{}}

      iex> create_timer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timer(attrs \\ %{}) do
    %Timer{}
    |> Timer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timer.

  ## Examples

      iex> update_timer(timer, %{field: new_value})
      {:ok, %Timer{}}

      iex> update_timer(timer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timer(%Timer{} = timer, attrs) do
    timer
    |> Timer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Timer.

  ## Examples

      iex> delete_timer(timer)
      {:ok, %Timer{}}

      iex> delete_timer(timer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timer(%Timer{} = timer) do
    Repo.delete(timer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timer changes.

  ## Examples

      iex> change_timer(timer)
      %Ecto.Changeset{source: %Timer{}}

  """
  def change_timer(%Timer{} = timer) do
    Timer.changeset(timer, %{})
  end
end
