defmodule App.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :person_id, :integer
      add :status, :integer
      add :text, :string

      timestamps()
    end
  end
end
