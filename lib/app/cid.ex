defmodule App.Cid do
  @moduledoc """
  Helper functions for adding `cid` to records transparently in a changeset pipeline.
  """

  @doc """
  `put_cid/1` as its' name suggests puts the `cid` for the record into the `changeset`.
  This is done transparently so nobody needs to _think_ about cids.
  """
  def put_cid(changeset) do
    if Map.has_key?(changeset.changes, :cid) do
      changeset
    else
      cid = Cid.cid(changeset.changes)
      %{changeset | changes: Map.put(changeset.changes, :cid, cid)}
    end
  end
end
