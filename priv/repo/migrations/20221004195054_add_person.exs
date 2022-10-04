defmodule App.Repo.Migrations.AddPerson do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:people, primary_key: false) do
      add(:person_id, :integer, primary_key: true)
      add(:name, :citext)

      timestamps()
    end

    # insert new people rows by select unique person_id from items and tags
    execute(
      "INSERT INTO people(person_id, inserted_at, updated_at)
        SELECT DISTINCT i.person_id, now(), now() FROM items as i UNION SELECT DISTINCT t.person_id, now(), now() from tags as t;"
    )

    create(unique_index(:people, [:name], name: :people_name_index))

    alter table(:items) do
      modify(:person_id, references(:people, column: :person_id))
    end

    alter table(:tags) do
      modify(:person_id, references(:people, column: :person_id))
    end
  end
end
