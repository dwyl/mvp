defmodule AppWeb.PersonControllerTest do
  use AppWeb.ConnCase

  import App.CtxFixtures

  @create_attrs %{auth_provider: "some auth_provider", givenName: "some givenName", key_id: 42, locale: "some locale", picture: "some picture"}
  @update_attrs %{auth_provider: "some updated auth_provider", givenName: "some updated givenName", key_id: 43, locale: "some updated locale", picture: "some updated picture"}
  @invalid_attrs %{auth_provider: nil, givenName: nil, key_id: nil, locale: nil, picture: nil}

  describe "index" do
    test "lists all people", %{conn: conn} do
      conn = get(conn, Routes.person_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing People"
    end
  end

  describe "new person" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.person_path(conn, :new))
      assert html_response(conn, 200) =~ "New Person"
    end
  end

  describe "create person" do
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
    setup [:create_person]

    test "renders form for editing chosen person", %{conn: conn, person: person} do
      conn = get(conn, Routes.person_path(conn, :edit, person))
      assert html_response(conn, 200) =~ "Edit Person"
    end
  end

  describe "update person" do
    setup [:create_person]

    test "redirects when data is valid", %{conn: conn, person: person} do
      conn = put(conn, Routes.person_path(conn, :update, person), person: @update_attrs)
      assert redirected_to(conn) == Routes.person_path(conn, :show, person)

      conn = get(conn, Routes.person_path(conn, :show, person))
      assert html_response(conn, 200) =~ "some updated auth_provider"
    end

    test "renders errors when data is invalid", %{conn: conn, person: person} do
      conn = put(conn, Routes.person_path(conn, :update, person), person: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Person"
    end
  end

  describe "delete person" do
    setup [:create_person]

    test "deletes chosen person", %{conn: conn, person: person} do
      conn = delete(conn, Routes.person_path(conn, :delete, person))
      assert redirected_to(conn) == Routes.person_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.person_path(conn, :show, person))
      end
    end
  end

  defp create_person(_) do
    person = person_fixture()
    %{person: person}
  end
end
