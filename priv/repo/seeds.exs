# Script for populating the database.
# You can run it as:
#
# mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of the repos directly.

if not Envar.is_set?("AUTH_API_KEY") do
  Envar.load(".env")
end

if Mix.env() == :dev do
  # Create item
  App.Item.create_item_with_tags(%{text: "random text", person_id: 0, status: 2, tags: [%{text: "first_tag", person_id: 0}]})

  # Create timers
  {:ok, _timer} =
    App.Timer.start(%{
      item_id: 1,
      start: "2023-01-19 15:52:00",
      stop: "2023-01-19 15:52:03"
    })

  {:ok, _timer2} =
    App.Timer.start(%{item_id: 1, start: "2023-01-19 15:55:00", stop: nil})

  # Create tags
  {:ok, _tag} =
    App.Tag.create_tag(%{text: "random test", person_id: 0, color: "#FFFFFF"})
end
