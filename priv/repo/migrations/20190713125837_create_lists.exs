defmodule App.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :title, :string
      add :human_id, references(:humans, on_delete: :nothing)
      add :status, references(:status, on_delete: :nothing)
      add :kind, references(:kinds, on_delete: :nothing)

      timestamps()
    end

    create index(:lists, [:human_id])
    create index(:lists, [:status])
    create index(:lists, [:kind])
  end
end
