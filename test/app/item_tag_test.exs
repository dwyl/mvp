defmodule App.ItemTagTest do
  use App.DataCase, async: true
  alias App.ItemTag

  test "valid tag changeset" do
    item_tag = %ItemTag{item_id: 1, tag_id: 1}
    assert item_tag.item_id == 1
    assert item_tag.tag_id == 1
  end
end
