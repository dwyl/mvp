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
end
