defmodule App.Repo.Migrations.CreateHumans do
  use Ecto.Migration

  def change do
    create table(:humans) do
      add :username, :binary
      add :username_hash, :binary
      add :email, :binary
      add :email_hash, :binary
      add :firstname, :binary
      add :lastname, :binary
      add :password_hash, :binary
      add :key_id, :integer
      add :status, references(:status, on_delete: :nothing)
      add :kind, references(:kinds, on_delete: :nothing)

      timestamps()
    end

    create index(:humans, [:status])
    create index(:humans, [:kind])
  end
end
