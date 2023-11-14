defmodule App.RepoTest do
  use ExUnit.Case
  alias App.Repo

  describe "validate_order/1" do
    test "validates 'asc' and 'desc' as a valid string order" do
      assert Repo.validate_order("asc") == true
      assert Repo.validate_order("desc") == true
    end

    test "validates :asc and :desc as a valid atom order" do
      assert Repo.validate_order(:asc) == true
      assert Repo.validate_order(:desc) == true
    end

    test "rejects invalid string order" do
      assert Repo.validate_order("invalid") == false
      assert Repo.validate_order(:invalid) == false
    end

    test "rejects SQL injection attempt" do
      assert Repo.validate_order("OR 1=1") == false
    end
  end

  describe "toggle_sort_order/1" do
    test "toggles :asc to :desc" do
      assert Repo.toggle_sort_order(:asc) == :desc
    end

    test "toggles :desc to :asc" do
      assert Repo.toggle_sort_order(:desc) == :asc
    end
  end
end
