defmodule AppWeb.TagControllerTest do
  use AppWeb.ConnCase
  alias App.Tag

  @create_attrs %{text: "tag1", person_id: 1, color: "#FCA5A5"}
  @update_attrs %{text: "tag1 updated", color: "#F87171"}
  @invalid_attrs %{text: nil, color: nil}

  def fixture(:tag) do
    {:ok, tag} = Tag.create_tag(@create_attrs)
    tag
  end

  describe "index" do
    test "lists all tags", %{conn: conn} do
      conn = get(conn, Routes.tag_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tags"
    end

    test "lists all tags and display logout button", %{conn: conn} do
      conn =
        conn
        |> assign(:jwt, AuthPlug.Token.generate_jwt!(%{id: 1, picture: ""}))
        |> get(Routes.tag_path(conn, :index))

      assert html_response(conn, 200) =~ "logout"
    end
  end

  describe "new tag" do
    test "renders form for creating a tag", %{conn: conn} do
      conn =
        conn
        |> assign(:jwt, AuthPlug.Token.generate_jwt!(%{id: 1, picture: ""}))
        |> get(Routes.tag_path(conn, :new))

      assert html_response(conn, 200) =~ "New Tag"
    end
  end

  describe "create tag" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        conn
        |> assign(:jwt, AuthPlug.Token.generate_jwt!(%{id: 1, picture: ""}))
        |> post(Routes.tag_path(conn, :create),
          tag: %{text: "new tag", color: "#FCA5A5"}
        )

      assert redirected_to(conn) == Routes.tag_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        conn
        |> assign(:jwt, AuthPlug.Token.generate_jwt!(%{id: 1, picture: ""}))
        |> post(Routes.tag_path(conn, :create), tag: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Tag"
    end
  end

  describe "edit tag" do
    setup [:create_tag]

    test "renders form for editing chosen tag", %{conn: conn, tag: tag} do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> get(Routes.tag_path(conn, :edit, tag))

      assert html_response(conn, 200) =~ "Edit Tag"
    end

    test "redirect to index when missing permission to edit the tag", %{
      conn: conn,
      tag: tag
    } do
      conn = get(conn, Routes.tag_path(conn, :edit, tag))

      assert redirected_to(conn) == Routes.tag_path(conn, :index)
    end
  end

  describe "update tag" do
    setup [:create_tag]

    test "redirects to show when data is valid", %{conn: conn, tag: tag} do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> put(Routes.tag_path(conn, :update, tag), tag: @update_attrs)

      assert redirected_to(conn) == Routes.tag_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn, tag: tag} do
      conn =
        conn
        |> assign(:jwt, AuthPlug.Token.generate_jwt!(%{id: 1, picture: ""}))
        |> put(Routes.tag_path(conn, :update, tag), tag: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Tag"
    end
  end

  describe "delete tag" do
    setup [:create_tag]

    test "deletes chosen tag", %{conn: conn, tag: tag} do
      conn =
        conn
        |> assign(:jwt, AuthPlug.Token.generate_jwt!(%{id: 1, picture: ""}))
        |> delete(Routes.tag_path(conn, :delete, tag))

      assert redirected_to(conn) == Routes.tag_path(conn, :index)
    end
  end

  defp create_tag(_) do
    tag = fixture(:tag)
    %{tag: tag}
  end

  defp create_person(_) do
    person = Person.create_person(%{"person_id" => 0, "name" => "guest"})
    _person = Person.create_person(%{"person_id" => 1, "name" => "Person1"})
    %{person: person}
  end
end
