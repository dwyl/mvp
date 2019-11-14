defmodule App.Repo.Migrations.CreateItemTagsAssociation do
  use Ecto.Migration

  def change do
    create table(:item_tags) do
      add :item_id, references(:items)
      add :tag_id, references(:tags)

      timestamps()
    end

    create unique_index(:item_tags, [:item_id, :tag_id])
  end
end
