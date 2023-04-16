defmodule App.Repo.Migrations.CreateListItems do
  use Ecto.Migration

  def change do
    create table(:list_items) do
      add :person_id, :integer
      add :position, :float
      add :item_id, references(:items, on_delete: :nothing)
      add :list_id, references(:lists, on_delete: :nothing)

      timestamps()
    end

    create index(:list_items, [:item_id])
    create index(:list_items, [:list_id])
  end
end
