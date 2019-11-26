defmodule App.Ctx.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :auth_token, Fields.Encrypted
    field :refresh_token, Fields.Encrypted
    field :key_id, :integer

    belongs_to :person, App.Ctx.Person
    timestamps()
  end

end
