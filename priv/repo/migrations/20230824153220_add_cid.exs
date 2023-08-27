defmodule App.Repo.Migrations.AddCid do
  use Ecto.Migration



  def up do
    alter table(:items) do
      add(:cid, :string)
    end
    # https://stackoverflow.com/questions/36723407/how-to-run-updating-in-migration-for-ecto
    flush()

  end
end
