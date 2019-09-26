defmodule App.Repo.Migrations.AddPersonIdToKind do
  use Ecto.Migration

  def change do
    alter table(:kinds) do
      add :person_id, references(:people, on_delete: :nothing)
    end
  end
end
