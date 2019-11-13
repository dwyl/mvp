defmodule App.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :text, :string
      add :person_id, references(:people, on_delete: :nothing)
      add :status, references(:status, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:person_id])
    create index(:items, [:status])
  end
end
