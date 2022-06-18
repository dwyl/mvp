defmodule App.StatusTest do
  use App.DataCase

  alias App.Status

  describe "status" do
    @valid_attrs %{text: "some text"}
    @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    def status_fixture(attrs \\ %{}) do
      {:ok, status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Status.create_status()

      status
    end

    test "list_status/0 returns all status" do
      status_fixture()
      assert Enum.count(Status.list_status()) > 1
    end

    test "get_status!/1 returns the status with given id" do
      status = status_fixture()
      assert Status.get_status!(status.id) == status
    end

    test "create_status/1 with valid data creates a status" do
      assert {:ok, %Status{} = status} = Status.create_status(@valid_attrs)
      assert status.text == "some text"
    end

    test "create_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Status.create_status(@invalid_attrs)
    end

    test "update_status/2 with valid data updates the status" do
      status = status_fixture()

      assert {:ok, %Status{} = status} =
               Status.update_status(status, @update_attrs)

      assert status.text == "some updated text"
    end

    test "update_status/2 with invalid data returns error changeset" do
      status = status_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Status.update_status(status, @invalid_attrs)

      assert status == Status.get_status!(status.id)
    end

    test "delete_status/1 deletes the status" do
      status = status_fixture()
      assert {:ok, %Status{}} = Status.delete_status(status)
      assert_raise Ecto.NoResultsError, fn -> Status.get_status!(status.id) end
    end

    test "change_status/1 returns a status changeset" do
      status = status_fixture()
      assert %Ecto.Changeset{} = Status.change_status(status)
    end

    test "upsert_status/1 inserts or updates a status" do
      # upsert (insert) a new status:
      status = Status.upsert_status(%{text: "Everything is Awesome!"})
      # attempt to upsert (create) an existing status: (created in seeds.exs)
      verified = Status.upsert_status(%{text: "verified", id: 1})
      assert verified.id == 1

      # update existing status:
      updata = %{
        id: status.id,
        text: "Everything is cool when you're part of a team!"
      }

      updated = Status.upsert_status(updata)
      assert updated.id == status.id
      assert updated.text == updata.text

      # updsert a record with id
      status2 = Status.upsert_status(%{text: "Amazing", id: 468})
      assert status2.id != 468
    end
  end
end
