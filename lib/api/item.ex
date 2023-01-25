defmodule API.Item do
  use AppWeb, :controller
  alias App.Item
  alias App.Tag
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
    item_attrs = %{
      text: Map.get(params, "text"),
      person_id: 0,
      status: 2
    }

    # Get array of tag changeset, if supplied
    tag_parameters_array = Map.get(params, "tags", [])

    # Item changeset, used to check if the the attributes are valid
    item_changeset = Item.changeset(%Item{}, item_attrs)

    # Validating item, tag array and if any tag already exists
    with true <- item_changeset.valid?,
         {:ok, tag_changeset_array} <-
           invalid_tags_from_params_array(
             tag_parameters_array,
             item_attrs.person_id
           ),
         {:ok, nil} <-
           tags_that_already_exist(tag_parameters_array, item_attrs.person_id) do
      # Creating item and tags and associate tags to item
      attrs = Map.put(item_attrs, :tags, tag_changeset_array)

      {:ok, %{model: item, version: _version}} =
        Item.create_item_with_tags(attrs)

      # Return `id` of created item
      id_item = Map.take(item, [:id])
      json(conn, id_item)
    else
      # Error creating item (attributes)
      false ->
        errors = make_changeset_errors_readable(item_changeset)

        json(
          conn |> put_status(400),
          errors
        )

      # First tag that already exists
      {:tag_already_exists, tag} ->
        errors = %{
          code: 400,
          message: "The tag \'" <> tag <> "\' already exists."
        }

        json(
          conn |> put_status(400),
          errors
        )

      # First tag that is invalid
      {:invalid_tag, tag_changeset} ->
        errors =
          make_changeset_errors_readable(tag_changeset)
          |> Map.put(:message, "At least one of the tags is malformed.")

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

  defp invalid_tags_from_params_array(tag_parameters_array, person_id) do
    tag_changeset_array =
      Enum.map(tag_parameters_array, fn tag_params ->
        # Add person_id and color if they are not specified
        tag = %Tag{
          person_id: Map.get(tag_params, "person_id", person_id),
          color: Map.get(tag_params, "color", App.Color.random()),
          text: Map.get(tag_params, "text")
        }

        # Return changeset
        Tag.changeset(tag)
      end)

    # Return first invalid tag changeset.
    # If none is found, return {:ok} and the array with tags converted to changesets
    case Enum.find(tag_changeset_array, fn chs -> not chs.valid? end) do
      nil -> {:ok, tag_changeset_array}
      tag_changeset -> {:invalid_tag, tag_changeset}
    end
  end

  defp tags_that_already_exist(tag_parameters_array, person_id) do
    if(length(tag_parameters_array) != 0) do
      # Retrieve tags texts from database
      db_tags_text = Tag.list_person_tags_text(person_id)

      tag_text_array =
        Enum.map(tag_parameters_array, fn tag -> Map.get(tag, "text", nil) end)

      # Return first tag that already exists in database. If none is found, return nil
      case Enum.find(db_tags_text, fn x -> Enum.member?(tag_text_array, x) end) do
        nil -> {:ok, nil}
        tag -> {:tag_already_exists, tag}
      end
    else
      {:ok, nil}
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
