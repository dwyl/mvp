defmodule App.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people) do
      add(:givenName, :binary)
      add(:auth_provider, :string)
      add(:key_id, :integer)
      add(:picture, :binary)
      add(:locale, :string)
      add(:status, :integer)

      timestamps()
    end
  end
end
