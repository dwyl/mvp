alias App.{Repo, Item, Tag, ItemTag}

# reset
Repo.delete_all(Item)
Repo.delete_all(Tag)

item1 = Repo.insert!(%Item{person_id: 1, text: "task1"})
item2 = Repo.insert!(%Item{person_id: 1, text: "task2"})

tag1 = Repo.insert!(%Tag{person_id: 1, text: "tag1"})
tag2 = Repo.insert!(%Tag{person_id: 1, text: "tag2"})

Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag1.id})
Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag2.id})
Repo.insert!(%ItemTag{item_id: item2.id, tag_id: tag2.id})
