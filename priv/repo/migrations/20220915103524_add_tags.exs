defmodule App.Repo.Migrations.AddTags do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:tags) do
      add(:text, :citext)
      add(:person_id, :integer)

      timestamps()
    end

    create(
      unique_index(:tags, [:text, :person_id], name: :tags_text_person_id_index)
    )
  end
end
