defmodule AppWeb.API.TagController do
  use AppWeb, :controller
  alias App.Tag
  import Ecto.Changeset

  def show(conn, %{"id" => id} = _params) do
    case Integer.parse(id) do
      # ID is an integer
      {id, _float} ->
        case Tag.get_tag(id) do
          nil ->
            errors = %{
              code: 404,
              message: "No tag found with the given \'id\'."
            }

            json(conn |> put_status(404), errors)

          item ->
            json(conn, item)
        end

      # ID is not an integer
      :error ->
        errors = %{
          code: 400,
          message: "The \'id\' is not an integer."
        }

        json(conn |> put_status(400), errors)
    end
  end

  def create(conn, params) do
    # Attributes to create tag
    # Person_id will be changed when auth is added
    attrs = %{
      text: Map.get(params, "text"),
      person_id: 0,
      color: Map.get(params, "color", App.Color.random())
    }

    case Tag.create_tag(attrs) do
      # Successfully creates tag
      {:ok, tag} ->
        id_tag = Map.take(tag, [:id])
        json(conn, id_tag)

      # Error creating tag
      {:error, %Ecto.Changeset{} = changeset} ->
        errors = make_changeset_errors_readable(changeset)

        json(
          conn |> put_status(400),
          errors
        )
    end
  end

  def update(conn, params) do
    id = Map.get(params, "id")

    # Get tag with the ID
    case Tag.get_tag(id) do
      nil ->
        errors = %{
          code: 404,
          message: "No tag found with the given \'id\'."
        }

        json(conn |> put_status(404), errors)

      # If tag is found, try to update it
      tag ->
        case Tag.update_tag(tag, params) do
          # Successfully updates tag
          {:ok, tag} ->
            json(conn, tag)

          # Error creating tag
          {:error, %Ecto.Changeset{} = changeset} ->
            errors = make_changeset_errors_readable(changeset)

            json(
              conn |> put_status(400),
              errors
            )
        end
    end
  end

  defp make_changeset_errors_readable(changeset) do
    errors = %{
      code: 400,
      message: "Malformed request"
    }

    changeset_errors = traverse_errors(changeset, fn {msg, _opts} -> msg end)
    Map.put(errors, :errors, changeset_errors)
  end
end
