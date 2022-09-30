defmodule App.Repo.Migrations.AddColorToTag do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add(:color, :text)
    end
  end
end
