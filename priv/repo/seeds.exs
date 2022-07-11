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
|> Enum.each(fn s ->
  Status.upsert(%{
    text: s.text,
    status_code: s.code
  })
end)

Person.create(%{
  givenName: "Beyoncé",
  auth_provider: "Google",
  status_code: 1
})
