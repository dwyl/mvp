defmodule App.Repo.Migrations.CreateItemTagsAssociation do
  use Ecto.Migration

  def change do
    create table(:item_tags) do
      add :item_id, references(:items)
<<<<<<< HEAD
      add :tag_id, references(:tags)
=======
      add :Tag_id, references(:tags)
>>>>>>> 8e3783e8f63177cbc789b7ed9094165e646b50d8

      timestamps()
    end

    create unique_index(:item_tags, [:item_id, :tag_id])
  end
end
