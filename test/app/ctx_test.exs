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

  describe "humans" do
    alias App.Ctx.Human

    @valid_attrs %{email: "some email", email_hash: "some email_hash", firstname: "some firstname", key_id: 42, lastname: "some lastname", password_hash: "some password_hash", username: "some username", username_hash: "some username_hash"}
    @update_attrs %{email: "some updated email", email_hash: "some updated email_hash", firstname: "some updated firstname", key_id: 43, lastname: "some updated lastname", password_hash: "some updated password_hash", username: "some updated username", username_hash: "some updated username_hash"}
    @invalid_attrs %{email: nil, email_hash: nil, firstname: nil, key_id: nil, lastname: nil, password_hash: nil, username: nil, username_hash: nil}

    def human_fixture(attrs \\ %{}) do
      {:ok, human} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_human()

      human
    end

    test "list_humans/0 returns all humans" do
      human = human_fixture()
      assert Ctx.list_humans() == [human]
    end

    test "get_human!/1 returns the human with given id" do
      human = human_fixture()
      assert Ctx.get_human!(human.id) == human
    end

    test "create_human/1 with valid data creates a human" do
      assert {:ok, %Human{} = human} = Ctx.create_human(@valid_attrs)
      assert human.email == "some email"
      assert human.email_hash == "some email_hash"
      assert human.firstname == "some firstname"
      assert human.key_id == 42
      assert human.lastname == "some lastname"
      assert human.password_hash == "some password_hash"
      assert human.username == "some username"
      assert human.username_hash == "some username_hash"
    end

    test "create_human/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_human(@invalid_attrs)
    end

    test "update_human/2 with valid data updates the human" do
      human = human_fixture()
      assert {:ok, %Human{} = human} = Ctx.update_human(human, @update_attrs)
      assert human.email == "some updated email"
      assert human.email_hash == "some updated email_hash"
      assert human.firstname == "some updated firstname"
      assert human.key_id == 43
      assert human.lastname == "some updated lastname"
      assert human.password_hash == "some updated password_hash"
      assert human.username == "some updated username"
      assert human.username_hash == "some updated username_hash"
    end

    test "update_human/2 with invalid data returns error changeset" do
      human = human_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_human(human, @invalid_attrs)
      assert human == Ctx.get_human!(human.id)
    end

    test "delete_human/1 deletes the human" do
      human = human_fixture()
      assert {:ok, %Human{}} = Ctx.delete_human(human)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_human!(human.id) end
    end

    test "change_human/1 returns a human changeset" do
      human = human_fixture()
      assert %Ecto.Changeset{} = Ctx.change_human(human)
    end
  end

  describe "items" do
    alias App.Ctx.Item

    @valid_attrs %{text: "some text"}
    @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_item()

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Ctx.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Ctx.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Ctx.create_item(@valid_attrs)
      assert item.text == "some text"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Ctx.update_item(item, @update_attrs)
      assert item.text == "some updated text"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_item(item, @invalid_attrs)
      assert item == Ctx.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Ctx.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Ctx.change_item(item)
    end
  end

  describe "lists" do
    alias App.Ctx.List

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def list_fixture(attrs \\ %{}) do
      {:ok, list} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_list()

      list
    end

    test "list_lists/0 returns all lists" do
      list = list_fixture()
      assert Ctx.list_lists() == [list]
    end

    test "get_list!/1 returns the list with given id" do
      list = list_fixture()
      assert Ctx.get_list!(list.id) == list
    end

    test "create_list/1 with valid data creates a list" do
      assert {:ok, %List{} = list} = Ctx.create_list(@valid_attrs)
      assert list.title == "some title"
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      list = list_fixture()
      assert {:ok, %List{} = list} = Ctx.update_list(list, @update_attrs)
      assert list.title == "some updated title"
    end

    test "update_list/2 with invalid data returns error changeset" do
      list = list_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_list(list, @invalid_attrs)
      assert list == Ctx.get_list!(list.id)
    end

    test "delete_list/1 deletes the list" do
      list = list_fixture()
      assert {:ok, %List{}} = Ctx.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_list!(list.id) end
    end

    test "change_list/1 returns a list changeset" do
      list = list_fixture()
      assert %Ecto.Changeset{} = Ctx.change_list(list)
    end
  end
end
