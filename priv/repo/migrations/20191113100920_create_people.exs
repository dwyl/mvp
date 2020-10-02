defmodule App.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :status, references(:status, on_delete: :nothing)
      add :tag, references(:tags, on_delete: :nothing)

      timestamps()
    end

    create index(:people, [:status])
    create index(:people, [:tag])
  end
end
