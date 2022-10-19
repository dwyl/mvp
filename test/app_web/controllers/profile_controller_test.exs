defmodule AppWeb.ProfileControllerTest do
  use AppWeb.ConnCase

  alias App.{Person, Repo}

  setup [:create_profile]

  @create_attrs %{person_id: 1, name: "person 1"}
  @update_attrs %{person_id: 1, name: "person 1 udpated"}
  @invalid_attrs %{person_id: 1, name: ""}

  describe "edit profile" do
    test "renders form for editing chosen profile", %{
      conn: conn,
      person: profile
    } do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> get(Routes.profile_path(conn, :edit, profile))

      assert html_response(conn, 200) =~ "Edit Profile"
    end

    test "redirect to index when missing permission to edit the profile", %{
      conn: conn,
      person: profile
    } do
      conn = get(conn, Routes.profile_path(conn, :edit, profile))

      assert redirected_to(conn) == "/"
    end
  end

  describe "update profile" do
    test "redirects to home page when data is valid", %{
      conn: conn,
      person: person
    } do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> put(Routes.profile_path(conn, :update, person), person: @update_attrs)

      assert redirected_to(conn) == "/"
    end

    test "renders errors when data is invalid", %{conn: conn, person: person} do
      conn =
        conn
        |> assign(:person, %{id: 1})
        |> put(Routes.profile_path(conn, :update, person),
          person: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Profile"
    end
  end

  def fixture(:person) do
    {:ok, person} = Person.create_person(@create_attrs)
    person
  end

  def fixture(:person_no_name) do
    {:ok, person} = Repo.insert(%Person{person_id: 404})
    person
  end

  defp create_profile(_) do
    person = fixture(:person)
    %{person: person}
  end

  defp create_profile_with_no_name(_) do
    person = fixture(:person_no_name)
    %{person: person}
  end
end
