defmodule AppWeb.PersonControllerTest do
  use AppWeb.ConnCase
  import App.SetupHelpers
  alias App.Ctx

  @create_attrs %{
    email: "a@b.com",
    email_hash: "some email_hash",
    familyName: "some familyName",
    givenName: "some givenName",
    key_id: 42,
    password_hash: "some password_hash",
    username: "some username",
    username_hash: "some username_hash"
  }
  @update_attrs %{
    email: "c@d.net",
    email_hash: "some updated email_hash",
    familyName: "some updated familyName",
    givenName: "some updated givenName",
    key_id: 43,
    password_hash: "some updated password_hash",
    username: "some updated username",
    username_hash: "some updated username_hash"
  }
  @invalid_attrs %{
    email: nil,
    email_hash: nil,
    familyName: nil,
    givenName: nil,
    key_id: nil,
    password_hash: nil,
    username: nil,
    username_hash: nil
  }

  def fixture(:person) do
    {:ok, person} = Ctx.create_person(@create_attrs)
    person
  end

  describe "index" do
    setup [:person_login]

    test "lists all people", %{conn: conn} do
      conn = get(conn, Routes.person_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing People"
    end
  end

  describe "new person" do
    setup [:person_login]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.person_path(conn, :new))
      assert html_response(conn, 200) =~ "New Person"
    end
  end

  describe "create person" do
    setup [:person_login]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.person_path(conn, :create), person: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.person_path(conn, :show, id)

      conn = get(conn, Routes.person_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Person"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.person_path(conn, :create), person: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Person"
    end
  end

  describe "edit person" do
    setup [:person_login, :create_person]

    test "renders form for editing chosen person", %{conn: conn, person: person} do
      conn = get(conn, Routes.person_path(conn, :edit, person))
      assert html_response(conn, 200) =~ "Edit Person"
    end
  end

  describe "update person" do
    setup [:person_login, :create_person]

    test "redirects when data is valid", %{conn: conn, person: person} do
      conn = put(conn, Routes.person_path(conn, :update, person), person: @update_attrs)
      assert redirected_to(conn) == Routes.person_path(conn, :show, person)

      conn = get(conn, Routes.person_path(conn, :show, person))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, person: person} do
      conn = put(conn, Routes.person_path(conn, :update, person), person: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Person"
    end
  end

  describe "delete person" do
    setup [:person_login, :create_person]

    test "deletes chosen person", %{conn: conn, person: person} do
      conn = delete(conn, Routes.person_path(conn, :delete, person))
      assert redirected_to(conn) == Routes.person_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.person_path(conn, :show, person))
      end
    end
  end

  describe "info person" do
    setup [:person_login, :create_person]

    test "display info person", %{conn: conn} do
      conn = get(conn, Routes.person_path(conn, :info))
      assert html_response(conn, 200)
    end
  end

  defp create_person(_) do
    person = fixture(:person)
    {:ok, person: person}
  end
end
