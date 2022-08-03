defmodule App.Repo.Migrations.AddAuthIdColumn do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add(:auth_id, :integer)
    end

    create(unique_index(:people, [:auth_id]))
  end
end
