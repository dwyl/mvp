defmodule App.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :givenName, :binary
      add :auth_provider, :string
      add :key_id, :integer
      add :picture, :binary
      add :locale, :string
      add :status_id, references(:status, on_delete: :nothing)
      add :tag_id, references(:tags, on_delete: :nothing)

      timestamps()
    end

    create index(:people, [:status_id])
    create index(:people, [:tag_id])
  end
end
