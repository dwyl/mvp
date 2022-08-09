defmodule App.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add(:text, :string)
      add(:person_id, :integer)
      add(:status, :integer)

      timestamps()
    end

    create(index(:items, [:person_id]))
  end
end
