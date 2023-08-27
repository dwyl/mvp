defmodule App.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :cid, :string
      add :name, :string
      add :person_id, :integer
      add :sort, :integer
      add :status, :integer

      timestamps()
    end
  end
end
