defmodule App.Repo.Migrations.CreateSessionTable do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :auth_token, :string
      add :refresh_token, :string
      add :key_id, :integer

      # delete all sessions for a user when the people is deleted
      add :person_id, references(:people, on_delete: :delete_all)
      timestamps()
    end
  end
end
