defmodule API.ItemTest do
  use AppWeb.ConnCase
  alias App.Item

  @tag_text "tag text"
  @create_attrs %{person_id: 42, status: 0, text: "some text"}
  @create_attrs_with_tags %{
    person_id: 42,
    status: 0,
    text: "some text",
    tags: [%{text: @tag_text}]
  }
  @create_attrs_with_invalid_tags %{
    person_id: 42,
    status: 0,
    text: "some text",
    tags: [%{invalid: ""}]
  }
  @update_attrs %{person_id: 43, status: 0, text: "some updated text"}
  @invalid_attrs %{person_id: nil, status: nil, text: nil}

  describe "show" do
    test "specific item", %{conn: conn} do
      {:ok, %{model: item, version: _version}} = Item.create_item(@create_attrs)
      conn = get(conn, Routes.api_item_path(conn, :show, item.id))

      assert json_response(conn, 200)["id"] == item.id
      assert json_response(conn, 200)["text"] == item.text
    end

    test "specific item with tags", %{conn: conn} do
      {:ok, %{model: item, version: _version}} = Item.create_item(@create_attrs)

      conn =
        get(conn, Routes.api_item_path(conn, :show, item.id), %{
          "embed" => "tags"
        })

      assert json_response(conn, 200)["id"] == item.id
      assert json_response(conn, 200)["text"] == item.text
      assert not is_nil(json_response(conn, 200)["tags"])
    end

    test "not found item", %{conn: conn} do
      conn = get(conn, Routes.api_item_path(conn, :show, -1))

      assert conn.status == 404
    end

    test "invalid id (not being an integer)", %{conn: conn} do
      conn = get(conn, Routes.api_item_path(conn, :show, "invalid"))
      assert conn.status == 400
    end
  end

  describe "create" do
    test "a valid item", %{conn: conn} do
      conn = post(conn, Routes.api_item_path(conn, :create, @create_attrs))

      assert json_response(conn, 200)
    end

    test "a valid item with tags", %{conn: conn} do
      conn =
        post(conn, Routes.api_item_path(conn, :create, @create_attrs_with_tags))

      assert json_response(conn, 200)
    end

    test "a valid item with tag that already exists", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.api_tag_path(conn, :create, %{
            text: @tag_text,
            person_id: @create_attrs_with_tags.person_id
          })
        )

      conn =
        post(conn, Routes.api_item_path(conn, :create, @create_attrs_with_tags))

      assert json_response(conn, 400)
      assert json_response(conn, 400)["message"] =~ "already exists"
    end

    test "a valid item with an invalid tag", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.api_item_path(conn, :create, @create_attrs_with_invalid_tags)
        )

      assert json_response(conn, 400)
      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end

    test "an invalid item", %{conn: conn} do
      conn = post(conn, Routes.api_item_path(conn, :create, @invalid_attrs))

      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end
  end

  describe "update" do
    test "item with valid attributes", %{conn: conn} do
      {:ok, %{model: item, version: _version}} = Item.create_item(@create_attrs)

      conn =
        put(conn, Routes.api_item_path(conn, :update, item.id, @update_attrs))

      assert json_response(conn, 200)["text"] == Map.get(@update_attrs, :text)
    end

    test "item with invalid attributes", %{conn: conn} do
      {:ok, %{model: item, version: _version}} = Item.create_item(@create_attrs)

      conn =
        put(conn, Routes.api_item_path(conn, :update, item.id, @invalid_attrs))

      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end

    test "item that doesn't exist", %{conn: conn} do
      conn = put(conn, Routes.api_item_path(conn, :update, -1, @invalid_attrs))

      assert conn.status == 404
    end
  end
end
