defmodule API.TagTest do
  use AppWeb.ConnCase
  alias App.Tag

  @create_attrs %{person_id: 42, color: "#FFFFFF", text: "some text"}
  @update_attrs %{person_id: 43, color: "#DDDDDD", text: "some updated text"}
  @invalid_attrs %{person_id: nil, color: nil, text: nil}
  @update_invalid_color %{color: "invalid"}

  describe "show" do
    test "specific tag", %{conn: conn} do
      {:ok, tag} = Tag.create_tag(@create_attrs)
      conn = get(conn, Routes.api_tag_path(conn, :show, tag.id))

      assert conn.status == 200
      assert json_response(conn, 200)["id"] == tag.id
      assert json_response(conn, 200)["text"] == tag.text
    end

    test "not found tag", %{conn: conn} do
      conn = get(conn, Routes.api_tag_path(conn, :show, -1))

      assert conn.status == 404
    end

    test "invalid id (not being an integer)", %{conn: conn} do
      conn = get(conn, Routes.api_tag_path(conn, :show, "invalid"))
      assert conn.status == 400
    end
  end

  describe "create" do
    test "a valid tag", %{conn: conn} do
      conn = post(conn, Routes.api_tag_path(conn, :create, @create_attrs))

      assert conn.status == 200
      assert json_response(conn, 200)["text"] == Map.get(@create_attrs, "text")

      assert json_response(conn, 200)["color"] ==
               Map.get(@create_attrs, "color")

      assert json_response(conn, 200)["person_id"] ==
               Map.get(@create_attrs, "person_id")
    end

    test "an invalid tag", %{conn: conn} do
      conn = post(conn, Routes.api_tag_path(conn, :create, @invalid_attrs))

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end
  end

  describe "update" do
    test "tag with valid attributes", %{conn: conn} do
      {:ok, tag} = Tag.create_tag(@create_attrs)
      conn = put(conn, Routes.api_tag_path(conn, :update, tag.id, @update_attrs))

      assert conn.status == 200
      assert json_response(conn, 200)["text"] == Map.get(@update_attrs, :text)
    end

    test "tag with invalid attributes", %{conn: conn} do
      {:ok, tag} = Tag.create_tag(@create_attrs)
      conn = put(conn, Routes.api_tag_path(conn, :update, tag.id, @invalid_attrs))

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end

    test "tag that doesn't exist", %{conn: conn} do
      {:ok, tag} = Tag.create_tag(@create_attrs)
      conn = put(conn, Routes.api_tag_path(conn, :update, -1, @update_attrs))

      assert conn.status == 404
    end

    test "a tag with invalid color", %{conn: conn} do
      {:ok, tag} = Tag.create_tag(@create_attrs)
      conn = put(conn, Routes.api_tag_path(conn, :update, tag.id, @update_invalid_color))

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["color"]) > 0
    end
  end
end
