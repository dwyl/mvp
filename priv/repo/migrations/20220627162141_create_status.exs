defmodule App.Repo.Migrations.CreateStatus do
  use Ecto.Migration

  def change do
    create table(:status) do
      add :text, :string
      add :status_code, :integer

      timestamps()
    end
  end
end
