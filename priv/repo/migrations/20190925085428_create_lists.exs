defmodule App.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :title, :string
      add :person_id, references(:people, on_delete: :nothing)
      add :status, references(:status, on_delete: :nothing)
      add :kind, references(:kinds, on_delete: :nothing)

      timestamps()
    end

    create index(:lists, [:person_id])
    create index(:lists, [:status])
    create index(:lists, [:kind])
  end
end
