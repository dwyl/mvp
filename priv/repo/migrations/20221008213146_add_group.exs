defmodule App.Repo.Migrations.AddGroup do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add(:name, :text)

      timestamps()
    end

    create table(:groups_people, primary_key: false) do
      add(:group_id, references(:groups, on_delete: :delete_all))

      add(
        :person_id,
        references(:people, column: :person_id, on_delete: :delete_all)
      )

      timestamps()
    end

    create(unique_index(:groups_people, [:group_id, :person_id]))

    create table(:groups_lists, primary_key: false) do
      add(:group_id, references(:groups, on_delete: :delete_all))
      add(:list_id, references(:lists, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:groups_lists, [:group_id, :list_id]))
  end
end
