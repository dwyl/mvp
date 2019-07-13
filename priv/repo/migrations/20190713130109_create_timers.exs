defmodule App.Repo.Migrations.CreateTimers do
  use Ecto.Migration

  def change do
    create table(:timers) do
      add :start, :naive_datetime
      add :end, :naive_datetime
      add :item_id, references(:items, on_delete: :nothing)
      add :human_id, references(:humans, on_delete: :nothing)

      timestamps()
    end

    create index(:timers, [:item_id])
    create index(:timers, [:human_id])
  end
end
