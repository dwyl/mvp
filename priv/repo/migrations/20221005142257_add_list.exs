defmodule App.Repo.Migrations.AddList do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:lists) do
      add(:name, :citext)
      add(:person_id, references(:people, column: :person_id))

      timestamps()
    end

    create(
      unique_index(:lists, [:name, :person_id],
        name: :lists_name_person_id_index
      )
    )

    create table(:items_lists, primary_key: false) do
      add(:item_id, references(:items, on_delete: :delete_all))
      add(:list_id, references(:tags, on_delete: :delete_all))

      timestamps()
    end

    # create a unique index on item_id and list_id to avoid
    # adding an item multiple time to the same list
    create(unique_index(:items_lists, [:item_id, :list_id]))
  end
end
