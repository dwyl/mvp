defmodule App.Repo.Migrations.AddTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:text, :string)

      timestamps()
    end

    create(unique_index(:tags, ["lower(text)"]))
  end
end
