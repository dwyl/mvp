defmodule App.CidTest do
  use App.DataCase, async: true

  @valid_attrs %{text: "Buy Bananas", person_id: 1, status: 2}

  test "put_cid/1 adds a `cid` for the `item` record" do
    # Create a changeset with a valid item record as the "changes":
    changeset_before = %{changes: @valid_attrs}
    # Should not yet have a cid:
    refute Map.has_key?(changeset_before.changes, :cid)

    # Confirm cid was added to the changes:
    changeset_with_cid = App.Cid.put_cid(changeset_before)
    assert changeset_with_cid.changes.cid == Cid.cid(@valid_attrs)

    # confirm idempotent:
    assert App.Cid.put_cid(changeset_with_cid) == changeset_with_cid
  end
end
