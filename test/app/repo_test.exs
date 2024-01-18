defmodule App.RepoTest do
  use ExUnit.Case
  alias App.Repo

  describe "toggle_sort_order/1" do
    test "toggles :asc to :desc" do
      assert Repo.toggle_sort_order(:asc) == :desc
    end

    test "toggles :desc to :asc" do
      assert Repo.toggle_sort_order(:desc) == :asc
    end
  end
end
