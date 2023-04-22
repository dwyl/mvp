alias App.{Repo, Item, Tag, ItemTag, List, ListItem}

# reset
Repo.delete_all(Item)
Repo.delete_all(Tag)

item1 = Repo.insert!(%Item{person_id: 1, text: "Buy Bananas"})
item2 = Repo.insert!(%Item{person_id: 1, text: "Make Banana Muffins"})
item3 = Repo.insert!(%Item{person_id: 1, text: "Eat Banana Muffins"})

tag1 = Repo.insert!(%Tag{person_id: 1, text: "shopping"})
tag2 = Repo.insert!(%Tag{person_id: 1, text: "baking"})
tag3 = Repo.insert!(%Tag{person_id: 1, text: "breakfast"})

Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag1.id})
Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag2.id})
Repo.insert!(%ItemTag{item_id: item2.id, tag_id: tag2.id})
Repo.insert!(%ItemTag{item_id: item3.id, tag_id: tag3.id})

# List!

list1_data = %{name: "Shopping List", person_id: 1, status: 2}
{:ok, %{model: list1, version: _version}} = List.create_list(list1_data)

list2_data = %{name: "Meal Plan", person_id: 1, status: 2}
{:ok, %{model: list2, version: _version}} = List.create_list(list2_data)

# Add items to lists:
{:ok, _list_item} = ListItem.add_list_item(item1, list1, 1, 1)
{:ok, _list_item} = ListItem.add_list_item(item2, list2, 1, 1)
{:ok, list_item} = ListItem.add_list_item(item3, list2, 1, 1)
