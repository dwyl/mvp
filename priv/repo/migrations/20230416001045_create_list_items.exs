defmodule App.Repo.Migrations.CreateListItems do
  use Ecto.Migration

  def change do
    create table(:list_items) do
      add :list_cid, :string
      add :list_id, references(:lists, on_delete: :nothing)
      add :person_id, :integer
      add :seq, :text

      timestamps()
    end

    create index(:list_items, [:list_id])
  end

end
