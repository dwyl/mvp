defmodule App.Repo.Migrations.AddItemsTags do
  use Ecto.Migration

  def change do
    create table(:items_tags, primary_key: false) do
      add(:item_id, references(:items, on_delete: :nothing))
      add(:tag_id, references(:tags, on_delete: :nothing))

      timestamps()
    end

    create(unique_index(:items_tags, [:item_id, :tag_id]))
  end
end
