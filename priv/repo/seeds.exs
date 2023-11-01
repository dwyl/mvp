# Script for populating the database.
# You can run it as:
#
# mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of the repos directly.

if not Envar.is_set?("AUTH_API_KEY") do
  Envar.load(".env")
end

# , List, ListItems}
alias App.{Repo, Item, Tag, Timer, ItemTag}
env = Application.fetch_env!(:app, :env)

if env == :test || env == :dev do
  # in case you need to update this to match your authenticated person_id:
  person_id = 0

  # reset
  Repo.delete_all(Item)
  Repo.delete_all(Tag)

  # Create "all"" List!
  {:ok, %{model: _all_list}} =
    App.List.create_list(%{name: "all", person_id: person_id, status: 2})

  # Create a few items for testing on localhost
  {:ok, %{model: item0}} =
    Item.create_item(%{person_id: person_id, text: "Use the MVP!", status: 3})

  {:ok, %{model: item1}} =
    Item.create_item(%{person_id: person_id, text: "Buy Bananas", status: 2})

  {:ok, %{model: item2}} =
    Item.create_item(%{
      person_id: person_id,
      text: "Make Banana Muffins",
      status: 2
    })

  {:ok, %{model: item3}} =
    Item.create_item(%{
      person_id: person_id,
      text: "Eat Banana Muffin!",
      status: 2
    })

  {:ok, %{model: item4}} =
    Item.create_item(%{
      person_id: person_id,
      text: "Go to Shops",
      status: 2
    })

  # Tags
  tag0 =
    Repo.insert!(%Tag{person_id: person_id, text: "start!", color: "#16A34A"})

  tag1 =
    Repo.insert!(%Tag{person_id: person_id, text: "shopping", color: "#F59E0B"})

  tag2 =
    Repo.insert!(%Tag{person_id: person_id, text: "baking", color: "#3B82F6"})

  tag3 =
    Repo.insert!(%Tag{person_id: person_id, text: "breakfast", color: "#FACC15"})

  # Associate items with tags:
  Repo.insert!(%ItemTag{item_id: item0.id, tag_id: tag0.id})
  Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag1.id})
  Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag2.id})
  Repo.insert!(%ItemTag{item_id: item2.id, tag_id: tag2.id})
  Repo.insert!(%ItemTag{item_id: item3.id, tag_id: tag3.id})
  Repo.insert!(%ItemTag{item_id: item4.id, tag_id: tag1.id})

  # Timers
  {:ok, started} =
    NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -1))

  {:ok, _timer1} =
    Timer.start(%{item_id: item0.id, person_id: person_id, start: started})

  # Add Cid to all existing items before adding them to the "all" list:
  App.Item.update_all_items_cid()

  # Add items to lists:
  # App.List.add_all_items_to_all_list_for_person_id(person_id)
end
