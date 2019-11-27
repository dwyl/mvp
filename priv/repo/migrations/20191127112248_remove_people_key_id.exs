defmodule App.Repo.Migrations.RemovePeopleKeyId do
  use Ecto.Migration

  def change do
    alter table("people") do
      remove :key_id
    end
  end
end
