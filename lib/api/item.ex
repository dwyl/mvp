defmodule API.Item do
  use AppWeb, :controller
  alias App.Item
  import Ecto.Changeset

  def show(conn, %{"id" => id} = _params) do
    case Integer.parse(id) do
      # ID is an integer
      {id, _float} ->
        case Item.get_item(id) do
          nil ->
            errors = %{
              code: 404,
              message: "No item found with the given \'id\'."
            }

            json(conn |> put_status(404), errors)

          item ->
            json(conn, item)
        end

      # ID is not an integer
      :error ->
        errors = %{
          code: 400,
          message: "Item \'id\' should be an integer."
        }

        json(conn |> put_status(400), errors)
    end
  end

  def create(conn, params) do
    # Attributes to create item
    # Person_id will be changed when auth is added
    attrs = %{
      text: Map.get(params, "text"),
      person_id: 0,
      status: 2
    }

    case Item.create_item(attrs) do
      # Successfully creates item
      {:ok, %{model: item, version: _version}} ->
        id_item = Map.take(item, [:id])
        json(conn, id_item)

      # Error creating item
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
    new_text = Map.get(params, "text")

    # Get item with the ID
    case Item.get_item(id) do
      nil ->
        errors = %{
          code: 404,
          message: "No item found with the given \'id\'."
        }

        json(conn |> put_status(404), errors)

      # If item is found, try to update it
      item ->
        case Item.update_item(item, %{text: new_text}) do
          # Successfully updates item
          {:ok, %{model: item, version: _version}} ->
            json(conn, item)

          # Error creating item
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
