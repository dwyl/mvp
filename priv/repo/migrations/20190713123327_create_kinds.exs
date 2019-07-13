defmodule App.Repo.Migrations.CreateKinds do
  use Ecto.Migration

  def change do
    create table(:kinds) do
      add :text, :string

      timestamps()
    end

  end
end
