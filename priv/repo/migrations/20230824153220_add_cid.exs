defmodule App.Repo.Migrations.AddCidToItem do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add(:cid, :string)
    end
  end
end
