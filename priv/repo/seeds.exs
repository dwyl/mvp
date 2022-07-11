# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias App.{Person, Status}

# Statuses: github.com/dwyl/statuses
Statuses.get_statuses()
|> Enum.each(fn status ->
  Status.upsert(Map.from_struct(status))
end)

verified_status = Status.get_by_text!(:verified)
IO.inspect(verified_status)

Person.create(
  %{
    givenName: "Beyoncé",
    auth_provider: "Google",
    status_code: 1
  },
  verified_status
)
