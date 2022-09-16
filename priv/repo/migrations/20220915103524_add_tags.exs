defmodule App.Repo.Migrations.AddTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:text, :string)
      add(:person_id, :integer)

      timestamps()
    end

    create(unique_index(:tags, ["lower(text)", :person_id]))
  end
end
