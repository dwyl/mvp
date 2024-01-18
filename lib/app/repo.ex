defmodule App.Repo do
  use Ecto.Repo,
    otp_app: :app,
    adapter: Ecto.Adapters.Postgres

  def toggle_sort_order(:asc), do: :desc
  def toggle_sort_order(:desc), do: :asc
end
