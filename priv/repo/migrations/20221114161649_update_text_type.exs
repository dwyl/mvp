defmodule App.Repo.Migrations.UpdateTextType do
  use Ecto.Migration

  def change do
    alter table(:items) do
      modify :text, :text
    end
  end
end
