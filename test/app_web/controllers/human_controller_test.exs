defmodule AppWeb.HumanControllerTest do
  use AppWeb.ConnCase

  alias App.Ctx

  @create_attrs %{email: "some email", email_hash: "some email_hash", firstname: "some firstname", key_id: 42, lastname: "some lastname", password_hash: "some password_hash", username: "some username", username_hash: "some username_hash"}
  @update_attrs %{email: "some updated email", email_hash: "some updated email_hash", firstname: "some updated firstname", key_id: 43, lastname: "some updated lastname", password_hash: "some updated password_hash", username: "some updated username", username_hash: "some updated username_hash"}
  @invalid_attrs %{email: nil, email_hash: nil, firstname: nil, key_id: nil, lastname: nil, password_hash: nil, username: nil, username_hash: nil}

  def fixture(:human) do
    {:ok, human} = Ctx.create_human(@create_attrs)
    human
  end

  describe "index" do
    test "lists all humans", %{conn: conn} do
      conn = get(conn, Routes.human_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Humans"
    end
  end

  describe "new human" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.human_path(conn, :new))
      assert html_response(conn, 200) =~ "New Human"
    end
  end

  describe "create human" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.human_path(conn, :create), human: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.human_path(conn, :show, id)

      conn = get(conn, Routes.human_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Human"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.human_path(conn, :create), human: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Human"
    end
  end

  describe "edit human" do
    setup [:create_human]

    test "renders form for editing chosen human", %{conn: conn, human: human} do
      conn = get(conn, Routes.human_path(conn, :edit, human))
      assert html_response(conn, 200) =~ "Edit Human"
    end
  end

  describe "update human" do
    setup [:create_human]

    test "redirects when data is valid", %{conn: conn, human: human} do
      conn = put(conn, Routes.human_path(conn, :update, human), human: @update_attrs)
      assert redirected_to(conn) == Routes.human_path(conn, :show, human)

      conn = get(conn, Routes.human_path(conn, :show, human))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, human: human} do
      conn = put(conn, Routes.human_path(conn, :update, human), human: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Human"
    end
  end

  describe "delete human" do
    setup [:create_human]

    test "deletes chosen human", %{conn: conn, human: human} do
      conn = delete(conn, Routes.human_path(conn, :delete, human))
      assert redirected_to(conn) == Routes.human_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.human_path(conn, :show, human))
      end
    end
  end

  defp create_human(_) do
    human = fixture(:human)
    {:ok, human: human}
  end
end
