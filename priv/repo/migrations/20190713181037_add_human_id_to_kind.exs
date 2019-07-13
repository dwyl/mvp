defmodule App.Repo.Migrations.AddHumanIdToKind do
  use Ecto.Migration

  def change do
    alter table(:kinds) do
      add :human_id, references(:humans, on_delete: :nothing)
    end
  end
end
