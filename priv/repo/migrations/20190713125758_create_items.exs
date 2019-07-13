defmodule App.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :text, :string
      add :human_id, references(:humans, on_delete: :nothing)
      add :status, references(:status, on_delete: :nothing)
      add :kind, references(:kinds, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:human_id])
    create index(:items, [:status])
    create index(:items, [:kind])
  end
end
