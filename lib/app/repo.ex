defmodule App.Repo do
  use Ecto.Repo,
    otp_app: :app,
    adapter: Ecto.Adapters.Postgres

  @doc """
  `validate_order/1` validates the ordering is one of `asc` or `desc`

  ## Examples

      iex> App.Repo.validate_order("asc")
      true

      iex> App.Repo.validate_order(:asc)
      true

      iex> App.Repo.validate_order(:invalid)
      false

      # Avoid common SQL injection attacks:
      iex> App.Repo.validate_order("OR 1=1")
      false
  """
  def validate_order(order) when is_bitstring(order) do
    Enum.member?(
      ~w(asc desc),
      order
    )
  end

  def validate_order(order) when is_atom(order) do
    Enum.member?(
      [:asc, :desc],
      order
    )
  end

  def toggle_sort_order(:asc), do: :desc
  def toggle_sort_order(:desc), do: :asc
end
