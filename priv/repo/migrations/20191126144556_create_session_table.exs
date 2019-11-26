defmodule App.Repo.Migrations.CreateSessionTable do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :auth_token, :string
      add :refresh_token, :string
      add :key_id, :integer

      add :person_id, references(:people, on_delete: :nothing)
      timestamps()
    end
  end
end
