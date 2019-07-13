defmodule App.CtxTest do
  use App.DataCase

  alias App.Ctx

  describe "kinds" do
    alias App.Ctx.Kind

    @valid_attrs %{text: "some text"}
    @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    def kind_fixture(attrs \\ %{}) do
      {:ok, kind} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_kind()

      kind
    end

    test "list_kinds/0 returns all kinds" do
      kind = kind_fixture()
      assert Ctx.list_kinds() == [kind]
    end

    test "get_kind!/1 returns the kind with given id" do
      kind = kind_fixture()
      assert Ctx.get_kind!(kind.id) == kind
    end

    test "create_kind/1 with valid data creates a kind" do
      assert {:ok, %Kind{} = kind} = Ctx.create_kind(@valid_attrs)
      assert kind.text == "some text"
    end

    test "create_kind/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_kind(@invalid_attrs)
    end

    test "update_kind/2 with valid data updates the kind" do
      kind = kind_fixture()
      assert {:ok, %Kind{} = kind} = Ctx.update_kind(kind, @update_attrs)
      assert kind.text == "some updated text"
    end

    test "update_kind/2 with invalid data returns error changeset" do
      kind = kind_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_kind(kind, @invalid_attrs)
      assert kind == Ctx.get_kind!(kind.id)
    end

    test "delete_kind/1 deletes the kind" do
      kind = kind_fixture()
      assert {:ok, %Kind{}} = Ctx.delete_kind(kind)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_kind!(kind.id) end
    end

    test "change_kind/1 returns a kind changeset" do
      kind = kind_fixture()
      assert %Ecto.Changeset{} = Ctx.change_kind(kind)
    end
  end

  describe "status" do
    alias App.Ctx.Status

    @valid_attrs %{text: "some text"}
    @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    def status_fixture(attrs \\ %{}) do
      {:ok, status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_status()

      status
    end

    test "list_status/0 returns all status" do
      status = status_fixture()
      assert Ctx.list_status() == [status]
    end

    test "get_status!/1 returns the status with given id" do
      status = status_fixture()
      assert Ctx.get_status!(status.id) == status
    end

    test "create_status/1 with valid data creates a status" do
      assert {:ok, %Status{} = status} = Ctx.create_status(@valid_attrs)
      assert status.text == "some text"
    end

    test "create_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_status(@invalid_attrs)
    end

    test "update_status/2 with valid data updates the status" do
      status = status_fixture()
      assert {:ok, %Status{} = status} = Ctx.update_status(status, @update_attrs)
      assert status.text == "some updated text"
    end

    test "update_status/2 with invalid data returns error changeset" do
      status = status_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_status(status, @invalid_attrs)
      assert status == Ctx.get_status!(status.id)
    end

    test "delete_status/1 deletes the status" do
      status = status_fixture()
      assert {:ok, %Status{}} = Ctx.delete_status(status)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_status!(status.id) end
    end

    test "change_status/1 returns a status changeset" do
      status = status_fixture()
      assert %Ecto.Changeset{} = Ctx.change_status(status)
    end
  end
end
