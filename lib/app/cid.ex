defmodule App.Cid do
  @moduledoc """
  Helper functions for adding `cid` to records transparently in a changeset pipeline.
  """

  @doc """
  `put_cid/1` as its' name suggests puts the `cid` for the record into the `changeset`.
  This is done transparently so nobody needs to _think_ about cids.
  """
  def put_cid(changeset) do
    # don't add a cid to a changeset that already has one
    if Map.has_key?(changeset.changes, :cid) do
      changeset
    else
      # Only add cid to changeset that has :name i.e. list.name or :text i.e. item.text
      if Map.has_key?(changeset.changes, :name) || Map.has_key?(changeset.changes, :text) do
        cid = Cid.cid(changeset.changes)
        %{changeset | changes: Map.put(changeset.changes, :cid, cid)}
      else
        changeset
      end
    end
  end
end
