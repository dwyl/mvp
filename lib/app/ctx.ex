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
end
