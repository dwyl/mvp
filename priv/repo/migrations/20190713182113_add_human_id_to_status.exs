defmodule App.Repo.Migrations.AddHumanIdToStatus do
  use Ecto.Migration

  def change do
    alter table(:status) do
      add :human_id, references(:humans, on_delete: :nothing)
    end
  end
end
