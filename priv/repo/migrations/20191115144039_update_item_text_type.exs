defmodule App.Repo.Migrations.UpdateItemTextType do
  use Ecto.Migration

  def change do
    alter table(:items) do
      modify :text, :text
    end
  end
end
