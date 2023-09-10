defmodule AppWeb.ListControllerTest do
  use AppWeb.ConnCase

  alias App.{List}

  @create_attrs %{name: "list1", person_id: 1}
  @update_attrs %{name: "list1 updated"}
  @invalid_attrs %{name: nil, person_id: 1}

  def fixture(:list) do
    {:ok, %{model: list}} = List.create_list(@create_attrs)
    list
  end

  describe "index" do
    test "lists all lists", %{conn: conn} do
      conn = get(conn, Routes.list_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing lists"
    end
  end

  describe "new list" do
    test "Display new list form", %{conn: conn} do
      conn = get(conn, Routes.list_path(conn, :new))
      assert html_response(conn, 200) =~ "New list"
    end
  end

  describe "create list" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> post(Routes.list_path(conn, :create), list: @create_attrs)

      assert redirected_to(conn) == Routes.list_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> post(Routes.list_path(conn, :create), list: @invalid_attrs)

      assert html_response(conn, 200) =~ "New list"
    end
  end

  describe "edit list" do
    setup [:create_list]

    test "renders form for editing chosen list", %{conn: conn, list: list} do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> get(Routes.list_path(conn, :edit, list))

      assert html_response(conn, 200) =~ "Edit List"
    end

    test "redirect to index when missing permission to edit the list", %{
      conn: conn,
      list: list
    } do
      conn = get(conn, Routes.list_path(conn, :edit, list))

      assert redirected_to(conn) == Routes.list_path(conn, :index)
    end
  end

  describe "update list" do
    setup [:create_list]

    test "redirects to index when data is valid", %{conn: conn, list: list} do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> put(Routes.list_path(conn, :update, list), list: @update_attrs)

      assert redirected_to(conn) == Routes.list_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn, list: list} do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> put(Routes.list_path(conn, :update, list), list: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit List"
    end
  end

  describe "delete list" do
    setup [:create_list]

    test "deletes chosen list", %{conn: conn, list: list} do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> delete(Routes.list_path(conn, :delete, list))

      assert redirected_to(conn) == Routes.list_path(conn, :index)
    end
  end

  defp create_list(_) do
    list = fixture(:list)
    %{list: list}
  end
end
