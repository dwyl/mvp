if not Envar.is_set?("AUTH_API_KEY") do
  Envar.load(".env")
end

# Create the default person
App.Person.upsert(
  %{
    givenName: "guest",
    auth_provider: "none",
    status_code: 1, # no association just an integer.
    id: 0 # stackoverflow.com/questions/32728179/primary-key-postgres-zero
  }
)
# |> IO.inspect(label: "default person")

App.Person.upsert(
  %{
    givenName: "Admin",
    auth_provider: "google",
    status_code: 1,
    id: 1
  }
)
