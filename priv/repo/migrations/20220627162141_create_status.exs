defmodule App.Repo.Migrations.CreateStatus do
  use Ecto.Migration

  def change do
    create table(:status) do
      add(:text, :string)
      add(:code, :integer)

      timestamps()
    end

    create(unique_index(:status, [:text]))
  end
end
