defmodule AppWeb.ItemControllerTest do
  use AppWeb.ConnCase
  import App.SetupHelpers
  alias App.Ctx

  @create_attrs %{text: "some text"}
  @update_attrs %{text: "some updated text"}
  @invalid_attrs %{text: nil}

  def fixture(:item) do
    {:ok, item} = Ctx.create_item(@create_attrs)
    item
  end

  describe "index" do
    setup [:person_login]

    test "lists all items", %{conn: conn} do
      conn = get(conn, Routes.item_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Items"
    end

    test "api - lists all items", %{conn: conn} do
      conn = get(conn, Routes.item_path(conn, :api_index))
      assert json_response(conn, 200)
    end
  end

  describe "new item" do
    setup [:person_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.item_path(conn, :new))
      assert html_response(conn, 200) =~ "New Item"
    end
  end

  describe "create item" do
    setup [:person_login]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.item_path(conn, :create), item: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.item_path(conn, :show, id)

      conn = get(conn, Routes.item_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Item"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.item_path(conn, :create), item: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Item"
    end
  end

  describe "edit item" do
    setup [:person_login, :create_item]

    test "renders form for editing chosen item", %{conn: conn, item: item} do
      conn = get(conn, Routes.item_path(conn, :edit, item))
      assert html_response(conn, 200) =~ "Edit Item"
    end
  end

  describe "update item" do
    setup [:person_login, :create_item]

    test "redirects when data is valid", %{conn: conn, item: item} do
      conn =
        put(conn, Routes.item_path(conn, :update, item), item: @update_attrs)

      assert redirected_to(conn) == Routes.item_path(conn, :show, item)

      conn = get(conn, Routes.item_path(conn, :show, item))
      assert html_response(conn, 200) =~ "some updated text"
    end

    test "renders errors when data is invalid", %{conn: conn, item: item} do
      conn =
        put(conn, Routes.item_path(conn, :update, item), item: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Item"
    end
  end

  describe "delete item" do
    setup [:create_item, :person_login]

    test "deletes chosen item", %{conn: conn, item: item} do
      conn = delete(conn, Routes.item_path(conn, :delete, item))
      assert redirected_to(conn) == Routes.item_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.item_path(conn, :show, item))
      end
    end
  end

  defp create_item(_) do
    item = fixture(:item)
    {:ok, item: item}
  end
end
