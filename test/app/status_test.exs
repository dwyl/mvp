defmodule App.StatusTest do
  use App.DataCase
  alias App.Status

  describe "status" do
    @valid_attrs %{text: :some_text}
    # @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    def status_fixture(attrs \\ %{}) do
      {:ok, status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Status.create()

      status
    end

    test "create/1 with valid data creates a status" do
      {:ok, status} = Status.create(@valid_attrs)
      assert status.text == :some_text
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Status.create(@invalid_attrs)
    end

    test "upsert/1 with valid data returns status" do
      {:ok, status} = Status.upsert(@valid_attrs)
      assert status.text == :some_text

      # confirm that upsert/1 does not re-create the same status:
      {:ok, status_again} = Status.upsert(@valid_attrs)
      assert status_again.id == status.id
    end

    test "upsert/1 with new data returns the new status" do
      new_status = %{text: :Hello_Simon!}
      {:ok, status} = Status.upsert(new_status)
      assert status.text == new_status.text
    end
  end
end
