defmodule App.Repo.Migrations.CreateListItemsAssociation do
  use Ecto.Migration

  def change do
    create table(:list_items) do
      add :item_id, references(:items)
      add :list_id, references(:lists)

      timestamps()
    end

    create unique_index(:list_items, [:item_id, :list_id])
  end

end
