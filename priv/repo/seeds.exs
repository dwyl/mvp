# Script for populating the database.
# You can run it as:
#
# mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of the repos directly.

if not Envar.is_set?("AUTH_API_KEY") do
  Envar.load(".env")
end

alias App.{Repo, Item, Tag, Timer, ItemTag, List, ListItem}
env = Application.fetch_env!(:app, :env)

if env == :test do
  # in case you need to update this to match your authenticated person_id:
  person_id = 0

  # reset
  Repo.delete_all(Item)
  Repo.delete_all(Tag)

  # Create a few items
  item1 = Repo.insert!(%Item{person_id: person_id, text: "Buy Bananas"})
  item2 = Repo.insert!(%Item{person_id: person_id, text: "Make Banana Muffins"})
  item3 = Repo.insert!(%Item{person_id: person_id, text: "Eat Banana Muffin!"})
  item4 = Repo.insert!(%Item{person_id: person_id, text: "Go to Shops"})

  # Tags
  tag1 = Repo.insert!(%Tag{person_id: person_id, text: "shopping"})
  tag2 = Repo.insert!(%Tag{person_id: person_id, text: "baking"})
  tag3 = Repo.insert!(%Tag{person_id: person_id, text: "breakfast"})

  Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag1.id})
  Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag2.id})
  Repo.insert!(%ItemTag{item_id: item2.id, tag_id: tag2.id})
  Repo.insert!(%ItemTag{item_id: item3.id, tag_id: tag3.id})

  # Timers
  {:ok, started} =
    NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -1))

  {:ok, _timer1} =
    Timer.start(%{item_id: item1.id, person_id: person_id, start: started})

  {:ok, _timer2} =
    Timer.start(%{item_id: item2.id, person_id: person_id, start: started})

  # List!
  list1_data = %{name: "Shopping List", person_id: person_id, status: 2}
  {:ok, %{model: list1, version: _version}} = List.create_list(list1_data)

  list2_data = %{name: "Meal Plan", person_id: person_id, status: 2}
  {:ok, %{model: list2, version: _version}} = List.create_list(list2_data)

  # Add items to lists:
  {:ok, _list_item} = ListItem.add_list_item(item1, list1, person_id, 1.0)
  {:ok, _list_item} = ListItem.add_list_item(item2, list2, person_id, 1.0)
  {:ok, _list_item} = ListItem.add_list_item(item3, list2, person_id, 1.0)
  {:ok, _list_item} = ListItem.add_list_item(item4, list1, person_id, 1.0)

  # Remove "Go to Shops" from list1:
  ListItem.remove_list_item(item4, list1, person_id)
end
