<div align="center">

# `API` Integration

</div>

This guide demonstrates
how to *extend* our MVP `Phoenix` App
so it also acts as an **`API`** 
returning `JSON` data.

`people` want to securely query
and update their data.
We want to ensure all actions 
that are performed in the Web UI
can also be done through our `REST API`
*and* `WebSocket API`
(for all real-time updates).

The API is tested using `Hoppscotch`.
For the setup guide, 
see:
[`lib/api/hoppscotch.md`](https://github.com/dwyl/mvp/blob/main/lib/api/hoppscotch.md)


<br />

- [`API` Integration](#api-integration)
- [1. Add `/api` scope and pipeline in `router.ex`](#1-add-api-scope-and-pipeline-in-routerex)
- [2. `API.Item` and `API.Timer`](#2-apiitem-and-apitimer)
  - [2.1 Adding tests](#21-adding-tests)
  - [2.2 Implementing the controllers](#22-implementing-the-controllers)
- [3. `JSON` serializing](#3-json-serializing)
- [4. Listing `timers` and `items` and validating updates](#4-listing-timers-and-items-and-validating-updates)
- [5. Error handling in `ErrorView`](#5-error-handling-in-errorview)
  - [5.1 Fixing tests](#51-fixing-tests)
- [6. Basic `API` Testing Using `cUrl`](#6-basic-api-testing-using-curl)
  - [6.1 _Create_ an `item` via `API` Request](#61-create-an-item-via-api-request)
  - [6.2 _Read_ the `item` via `API`](#62-read-the-item-via-api)
  - [6.3 Create a `Timer` for your `item`](#63-create-a-timer-for-your-item)
  - [6.4 _Stop_ the `Timer`](#64-stop-the-timer)
  - [6.5 Updating a `Timer`](#65-updating-a-timer)
- [7. Adding `API.Tag`](#7-adding-apitag)
  - [7.1 Updating scope in `router.ex` and tests](#71-updating-scope-in-routerex-and-tests)
  - [7.2 Implementing `API.Tag` CRUD operations](#72-implementing-apitag-crud-operations)
    - [7.2.1 Adding tests](#721-adding-tests)
    - [7.2.2 Adding `JSON` encoding and operations to `Tag` schema](#722-adding-json-encoding-and-operations-to-tag-schema)
    - [7.2.3 Implementing `lib/api/tag.ex`](#723-implementing-libapitagex)
  - [7.3 Allowing creating `item` with `tags`](#73-allowing-creating-item-with-tags)
    - [7.3.1 Adding tests](#731-adding-tests)
    - [7.3.2 Implementing `list_person_tags_text/0`](#732-implementing-list_person_tags_text0)
    - [7.3.3 Updating `:create` in `lib/api/item.ex`](#733-updating-create-in-libapiitemex)
      - [7.3.3.1 Creating `tag` validating functions](#7331-creating-tag-validating-functions)
      - [7.3.3.2 Finishing up `lib/api/item.ex`'s `create` function](#7332-finishing-up-libapiitemexs-create-function)
  - [7.3 Fetching items with embedded tags](#73-fetching-items-with-embedded-tags)
    - [7.3.1 Adding tests](#731-adding-tests-1)
    - [7.3.2 Returning `item` with `tags` on endpoint](#732-returning-item-with-tags-on-endpoint)
    - [7.3.3 A note about `Jason` encoding](#733-a-note-about-jason-encoding)
- [Done! ✅](#done-)


<br />


# 1. Add `/api` scope and pipeline in `router.ex`

We want all `API` requests
to be made under the `/api` namespace.
This is easier for us to manage changes to `API`
that don't create unnecessary complexity in the `LiveView` code.

Let's start by opening `lib/router.ex` 
and create a new `:api` pipeline
to be used under `scope "/api"`:

```elixir

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :authOptional do
    plug(AuthPlugOptional)
  end

  scope "/api", AppWeb do
    pipe_through [:api, :authOptional]

    resources "/items", API.ItemController, only: [:create, :update, :show]
    resources "/items/:item_id/timers", API.TimerController, only: [:create, :update, :show, :index]

    put "/timers/:id", Timer, :stop
  end
```

We are creating an `:api` pipeline 
that will only accept and return `json` objects.
`:fetch_session` is added as a plug 
because `:authOptional` requires us to do so.

Every request that is routed to `/api`
will be piped through both the `:api` and `:authOptional` pipelines.

You might have noticed two new controllers:
`API.ItemController` and `API.TimerController`.
We are going to need to create these to handle our requests!

# 2. `API.Item` and `API.Timer`

Before creating our controller, let's define our requirements. We want the API to:

- read contents of an `item`/`timer`
- list `timers` of an `item`
- create an `item` and return only the created `id`.
- edit an `item`
- stop a `timer`
- update a `timer`
- create a `timer`

We want each endpoint to respond appropriately if any data is invalid, 
the response body and status should inform the `person` what went wrong. 
We can leverage changesets to validate the `item` and `timer`
and check if it's correctly formatted.

## 2.1 Adding tests

Let's approach this
with a [`TDD mindset`](https://github.com/dwyl/learn-tdd)
and create our tests first!

Create two new files:
- `test/api/item_test.exs`
- `test/api/timer_test.exs`

Before implementing,
we recommend giving a look at 
[`learn-api-design`](https://github.com/dwyl/learn-api-design),
we are going to be using some best practices described there!

We want the `API` requests 
to be handled gracefully 
when an error occurs.
The `person` using the `API` 
[**should be shown _meaningful_ errors**](https://github.com/dwyl/learn-api-design/blob/main/README.md#show-meaningful-errors).
Therefore, we need to test how our API behaves
when invalid attributes are requested
and/or an error occurs **and where**.

Open `test/api/item_test.exs` 
and add the following code:

```elixir
defmodule API.ItemTest do
use AppWeb.ConnCase
  alias App.Item

  @create_attrs %{person_id: 42, status: 0, text: "some text"}
  @update_attrs %{person_id: 43, status: 0, text: "some updated text"}
  @invalid_attrs %{person_id: nil, status: nil, text: nil}

  describe "show" do
    test "specific item", %{conn: conn} do
      {:ok, %{model: item, version: _version}} = Item.create_item(@create_attrs)
      conn = get(conn, Routes.item_path(conn, :show, item.id))

      assert json_response(conn, 200)["id"] == item.id
      assert json_response(conn, 200)["text"] == item.text
    end

    test "not found item", %{conn: conn} do
      conn = get(conn, Routes.item_path(conn, :show, -1))

      assert conn.status == 404
    end

    test "invalid id (not being an integer)", %{conn: conn} do
      conn = get(conn, Routes.item_path(conn, :show, "invalid"))
      assert conn.status == 400
    end
  end

  describe "create" do
    test "a valid item", %{conn: conn} do
      conn = post(conn, Routes.item_path(conn, :create, @create_attrs))

      assert json_response(conn, 200)["text"] == Map.get(@create_attrs, "text")

      assert json_response(conn, 200)["status"] ==
               Map.get(@create_attrs, "status")

      assert json_response(conn, 200)["person_id"] ==
               Map.get(@create_attrs, "person_id")
    end

    test "an invalid item", %{conn: conn} do
      conn = post(conn, Routes.item_path(conn, :create, @invalid_attrs))

      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end
  end

  describe "update" do
    test "item with valid attributes", %{conn: conn} do
      {:ok, %{model: item, version: _version}} = Item.create_item(@create_attrs)
      conn = put(conn, Routes.item_path(conn, :update, item.id, @update_attrs))

      assert json_response(conn, 200)["text"] == Map.get(@update_attrs, :text)
    end

    test "item with invalid attributes", %{conn: conn} do
      {:ok, %{model: item, version: _version}} = Item.create_item(@create_attrs)
      conn = put(conn, Routes.item_path(conn, :update, item.id, @invalid_attrs))

      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end

    test "item that doesn't exist", %{conn: conn} do
      conn = put(conn, Routes.item_path(conn, :update, -1, @invalid_attrs))

      assert conn.status == 404
    end
  end
end
```

In `/item`, 
a `person` will be able to
**create**, **update** or **query a single item**.
In each test we are testing 
successful scenarios (the [Happy Path](https://en.wikipedia.org/wiki/Happy_path)),
alongside situations where the person
requests non-existent items
or tries to create new ones with invalid attributes.

Next, in the `test/api/timer_test.exs` file:

```elixir
defmodule API.TimerTest do
  use AppWeb.ConnCase
  alias App.Timer
  alias App.Item

  @create_item_attrs %{person_id: 42, status: 0, text: "some text"}

  @create_attrs %{item_id: 42, start: "2022-10-27T00:00:00"}
  @update_attrs %{item_id: 43, start: "2022-10-28T00:00:00"}
  @invalid_attrs %{item_id: nil, start: nil}

  describe "index" do
    test "timers", %{conn: conn} do
      # Create item and timer
      {item, _timer} = item_and_timer_fixture()

      conn = get(conn, Routes.timer_path(conn, :index, item.id))

      assert conn.status == 200
      assert length(json_response(conn, 200)) == 1
    end
  end

  describe "show" do
    test "specific timer", %{conn: conn} do
      # Create item and timer
      {item, timer} = item_and_timer_fixture()

      conn = get(conn, Routes.timer_path(conn, :show, item.id, timer.id))

      assert conn.status == 200
      assert json_response(conn, 200)["id"] == timer.id
    end

    test "not found timer", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      conn = get(conn, Routes.timer_path(conn, :show, item.id, -1))

      assert conn.status == 404
    end

    test "invalid id (not being an integer)", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      conn = get(conn, Routes.timer_path(conn, :show, item.id, "invalid"))
      assert conn.status == 400
    end
  end

  describe "create" do
    test "a valid timer", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      # Create timer
      conn =
        post(conn, Routes.timer_path(conn, :create, item.id, @create_attrs))

      assert conn.status == 200

      assert json_response(conn, 200)["start"] ==
               Map.get(@create_attrs, "start")
    end

    test "an invalid timer", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      conn =
        post(conn, Routes.timer_path(conn, :create, item.id, @invalid_attrs))

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["start"]) > 0
    end

    test "a timer with empty body", %{conn: conn} do
      # Create item
      {:ok, %{model: item, version: _version}} =
        Item.create_item(@create_item_attrs)

      conn =
        post(conn, Routes.timer_path(conn, :create, item.id, %{}))

      assert conn.status == 200
    end
  end

  describe "stop" do
    test "timer without any attributes", %{conn: conn} do
      # Create item and timer
      {item, timer} = item_and_timer_fixture()

      conn =
        put(
          conn,
          Routes.timer_path(conn, :stop, timer.id, %{})
        )

      assert conn.status == 200
    end

    test "timer that doesn't exist", %{conn: conn} do
      conn = put(conn, Routes.timer_path(conn, :stop, -1, %{}))

      assert conn.status == 404
    end

    test "timer that has already stopped", %{conn: conn} do
      # Create item and timer
      {_item, timer} = item_and_timer_fixture()

      # Stop timer
      now = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()
      {:ok, timer} = Timer.update_timer(timer, %{stop: now})

      conn =
        put(
          conn,
          Routes.timer_path(conn, :stop, timer.id, %{})
        )

      assert conn.status == 403
    end
  end

  describe "update" do
    test "timer with valid attributes", %{conn: conn} do
      # Create item and timer
      {item, timer} = item_and_timer_fixture()

      conn =
        put(
          conn,
          Routes.timer_path(conn, :update, item.id, timer.id, @update_attrs)
        )

      assert conn.status == 200
      assert json_response(conn, 200)["start"] == Map.get(@update_attrs, :start)
    end

    test "timer with invalid attributes", %{conn: conn} do
      # Create item and timer
      {item, timer} = item_and_timer_fixture()

      conn =
        put(
          conn,
          Routes.timer_path(conn, :update, item.id, timer.id, @invalid_attrs)
        )

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["start"]) > 0
    end

    test "timer that doesn't exist", %{conn: conn} do
      conn = put(conn, Routes.timer_path(conn, :update, -1, -1, @invalid_attrs))

      assert conn.status == 404
    end
  end

  defp item_and_timer_fixture() do
    # Create item
    {:ok, %{model: item, version: _version}} =
      Item.create_item(@create_item_attrs)

    # Create timer
    started = NaiveDateTime.utc_now()
    {:ok, timer} = Timer.start(%{item_id: item.id, start: started})

    {item, timer}
  end
end
```

If you run `mix test`, they will fail,
because these functions aren't defined.

## 2.2 Implementing the controllers

It's time to implement our sweet controllers!
Let's start with `API.Item`.

Create file with the path: 
`lib/api/item.ex`
and add the following code:

```elixir
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
          message: "The \'id\' is not an integer."
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
```

Each function should be self-explanatory.

- `:show` pertains to `GET api/items/:id` 
and returns an `item` object.
- `:create` refers to `POST api/items/:id` 
and yields the `id` of the newly created `item` object.
- `:update` refers to `PUT or PATCH api/items/:id` 
and returns the updated `item` object.

Do notice that, since we are using 
[`PaperTrail`](https://github.com/izelnakri/paper_trail)
to record changes to the `items`,
database operations return 
a map with `"model"` and `"version"`,
hence why we are pattern-matching it when
updating and create items.

```elixir
{:ok, %{model: item, version: _version}} -> Item.create_item(attrs)
```

In cases where, for example,
`:id` is invalid when creating an `item`;
or there are missing fields when creating an `item`,
an error message is displayed in which fields
the changeset validation yielded errors.
To display errors meaningfully, 
we *traverse the errors* in the changeset
inside the `make_changeset_errors_readable/1` function.

For example, 
if you try to make a `POST` request
to `api/items` with the following body:

```json
{
    "invalid": "31231"
}
```

The API wil return a `400 Bad Request` HTTP status code
with the following message,
since it was expecting a `text` field:

```json
{
    "code": 400,
    "errors": {
        "text": [
            "can't be blank"
        ]
    },
    "message": "Malformed request"
}
```

To retrieve/update/create an `item`,
we are simply calling the schema functions
defined in `lib/app/timer.ex`.

Create a new file with the path:
`lib/api/timer.ex`
and add the following code:

```elixir
defmodule API.Timer do
  use AppWeb, :controller
  alias App.Timer
  import Ecto.Changeset

  def index(conn, params) do
    item_id = Map.get(params, "item_id")

    timers = Timer.list_timers(item_id)
    json(conn, timers)
  end

  def stop(conn, params) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()
    id = Map.get(params, "id")

    # Attributes to update timer
    attrs_to_update = %{
      stop: now
    }

    # Fetching associated timer
    case Timer.get_timer(id) do
      nil ->
        errors = %{
          code: 404,
          message: "No timer found with the given \'id\'."
        }
        json(conn |> put_status(404), errors)

      # If timer is found, try to update it
      timer ->

        # If the timer has already stopped, throw error
        if not is_nil(timer.stop) do
          errors = %{
            code: 403,
            message: "Timer with the given \'id\' has already stopped."
          }
          json(conn |> put_status(403), errors)

        # If timer is ongoing, try to update
        else
          case Timer.update_timer(timer, attrs_to_update) do
            # Successfully updates timer
            {:ok, timer} ->
              json(conn, timer)
          end
        end
    end
  end

  def show(conn, %{"id" => id} = _params) do
    case Integer.parse(id) do
      # ID is an integer
      {id, _float} ->
        case Timer.get_timer(id) do
          nil ->
            errors = %{
              code: 404,
              message: "No timer found with the given \'id\'."
            }

            json(conn |> put_status(404), errors)

          timer ->
            json(conn, timer)
        end

      # ID is not an integer
      :error ->
        errors = %{
          code: 400,
          message: "Timer \'id\' should be an integer."
        }

        json(conn |> put_status(400), errors)
    end
  end

  def create(conn, params) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()

    # Attributes to create timer
    attrs = %{
      item_id: Map.get(params, "item_id"),
      start: Map.get(params, "start", now),
      stop: Map.get(params, "stop")
    }

    case Timer.start(attrs) do
      # Successfully creates timer
      {:ok, timer} ->
        id_timer = Map.take(timer, [:id])
        json(conn, id_timer)

      # Error creating timer
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

    # Attributes to update timer
    attrs_to_update = %{
      start: Map.get(params, "start"),
      stop: Map.get(params, "stop")
    }

    case Timer.get_timer(id) do
      nil ->
        errors = %{
          code: 404,
          message: "No timer found with the given \'id\'."
        }
        json(conn |> put_status(404), errors)

      # If timer is found, try to update it
      timer ->
        case Timer.update_timer(timer, attrs_to_update) do
          # Successfully updates timer
          {:ok, timer} ->
            json(conn, timer)


          # Error updating timer
          {:error, %Ecto.Changeset{} = changeset} ->
            errors = make_changeset_errors_readable(changeset)

            json( conn |> put_status(400), errors )
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
```

The same set of conditions and operations
occur in `timer_controller.ex`.
The only difference is that there's an extra operation:
the person can list the `timers` for a specific `item`.
For this, we are using a function
that *is not yet implemented*
in `lib/app/timer.ex` - **`list_timers/1`**.


# 3. `JSON` serializing

Let's look at `index` in `lib/app/timer.ex`.
You may notice that we are returning a `JSON`
with `json(conn, timers)`.

```elixir
  def index(conn, params) do
    item_id = Map.get(params, "item_id")

    timers = Timer.list_timers(item_id)
    json(conn, timers)
  end
```

However, as it stands, 
[`Jason`](https://github.com/michalmuskala/jason)
(which is the package that serializes and deserializes `JSON` objects),
doesn't know how to encode/decode our `timer` and `item` objects.

We can **derive the implementation**
by specifying which fields should be encoded to `JSON`.
We are going to be using `Jason.Encoder` for this.

In `lib/app/timer.ex`,
add the line on top of the schema, like so.

```elixir
  @derive {Jason.Encoder, only: [:id, :start, :stop]}
  schema "timers" do
    field :start, :naive_datetime
    field :stop, :naive_datetime
    belongs_to :item, Item, references: :id, foreign_key: :item_id

    timestamps()
  end
```

This will allow `Jason` to encode 
any `Timer` struct when returning API calls.

Let's do the same for `Item`!
In `lib/app/timer.ex`,

```elixir
  @derive {Jason.Encoder, only: [:id, :person_id, :status, :text]}
  schema "items" do
    field :person_id, :integer
    field :status, :integer
    field :text, :string

    has_many :timer, Timer
    many_to_many(:tags, Tag, join_through: ItemTag, on_replace: :delete)

    timestamps()
  end
```

By leveraging the `@derive` annotation,
we can easily encode our structs 
and serialize them as `JSON` objects
so they can be returned to the person
using the API! ✨

# 4. Listing `timers` and `items` and validating updates

Let's implement `list_timers/1`
in `lib/app/timer.ex`.

```elixir
  def list_timers(item_id) do
    Timer
    |> where(item_id: ^item_id)
    |> order_by(:id)
    |> Repo.all()
  end
```

Simple, isn't it?
We are just retrieving every `timer` object
of a given `item.id`.

We are also using `Item.get_item/1`
and `Timer.get_timer/1`, 
instead of using 
[bang (!) functions](https://stackoverflow.com/questions/33324302/what-are-elixir-bang-functions).
We are not using bang functions
because they throw Exceptions.
And using `try/rescue` constructs
[isn't a good practice.](https://elixir-lang.org/getting-started/try-catch-and-rescue.html)

To validate parameters and return errors,
we need to be able to "catch" these scenarios.
Therefore, we create non-bang functions
that don't raise exceptions.

In `app/lib/timer.ex`, 
add `get_timer/1`.

```elixir
  def get_timer(id), do: Repo.get(Timer, id)
```

In `app/lib/item.ex`, 
add `get_item/1`.

```elixir
  def get_item(id) do
    Item
    |> Repo.get(id)
    |> Repo.preload(tags: from(t in Tag, order_by: t.text))
  end
```

Digressing,
when updating or creating a `timer`, 
we want to make sure the `stop` field
is not *before* `start`,
as it simply wouldn't make sense!
To fix this (and give the person using the API
an error explaining in case this happens),
we will create our own 
[**changeset datetime validator**](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-validations-and-constraints).

We will going to validate the two dates
being passed and check if `stop > start`.
Inside `lib/app/timer.ex`,
add the following private function.

```elixir
  defp validate_start_before_stop(changeset) do
    start = get_field(changeset, :start)
    stop = get_field(changeset, :stop)

    # If start or stop  is nil, no comparison occurs.
    case is_nil(stop) or is_nil(start) do
      true -> changeset
      false ->
        if NaiveDateTime.compare(start, stop) == :gt do
          add_error(changeset, :start, "cannot be later than 'stop'")
        else
          changeset
        end
    end
  end
```
 
If `stop` or `start` is `nil`, we can't compare the datetimes,
so we just skip the validation.
This usually happens when creating a timer that is ongoing
(`stop` is `nil`).
We won't block creating `timers` with `stop` with a `nil` value.

Now let's use this validator!
Pipe `start/1` and `update_timer/1`
with our newly created validator,
like so.

```elixir
  def start(attrs \\ %{}) do
    %Timer{}
    |> changeset(attrs)
    |> validate_start_before_stop()
    |> Repo.insert()
  end

  def update_timer(attrs \\ %{}) do
    get_timer!(attrs.id)
    |> changeset(attrs)
    |> validate_start_before_stop()
    |> Repo.update()
  end
```

If you try to create a `timer`
where `start` is *after* `stop`, 
it will error out!

<img width="1339" alt="error_datetimes" src="https://user-images.githubusercontent.com/17494745/212123844-9a03850d-ac31-47a6-a9f4-d32d317f90bb.png">

# 5. Error handling in `ErrorView`

Sometimes the user might access a route that is not defined.
If you are running on localhost and try to access a random route, like:

```sh
curl -X GET http://localhost:4000/api/items/1/invalidroute -H 'Content-Type: application/json'
```

You will receive an `HTML` response.
This `HTML` pertains to the debug screen 
you can see on your browser.

![image](https://user-images.githubusercontent.com/17494745/212749069-82cf85ff-ab6f-4a2f-801c-cae0e9e3229a.png)

The reason this debug screen is appearing 
is because we are running on **`dev` mode**.
If we ran this in production
or *toggle `:debug_errors` to `false` 
in `config/dev.exs`, 
we would get a simple `"Not Found"` text.

<img width="693" alt="image" src="https://user-images.githubusercontent.com/17494745/212878187-5f696dbb-8bbc-4b46-ab15-f010af5ce394.png">

All of this behaviour occurs
in `lib/app_web/views/error_view.ex`.

```elixir
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
```

When a browser-based call occurs to an undefined route, 
`template` has a value of `404.html`.
Conversely, in our API-scoped routes, 
a value of `404.json` is expected.
[Phoenix renders each one according to the `Accept` request header of the incoming request.](https://github.com/phoenixframework/phoenix/issues/1879)

We should extend this behaviour 
for when requests have `Content-type` as `application/json`
to also return a `json` response, 
instead of `HTML` (which Phoenix by default does).

For this, 
add the following function
inside `lib/app_web/views/error_view.ex`.

```elixir
  def template_not_found(template, %{:conn => conn}) do
    acceptHeader =
      Enum.at(Plug.Conn.get_req_header(conn, "content-type"), 0, "")

    isJson =
      String.contains?(acceptHeader, "application/json") or
        String.match?(template, ~r/.*\.json/)

    if isJson do
      # If `Content-Type` is `json` but the `Accept` header is not passed, Phoenix considers this as an `.html` request.
      # We want to return a JSON, hence why we check if Phoenix considers this an `.html` request.
      #
      # If so, we return a JSON with appropriate headers.
      # We try to return a meaningful error if it exists (:reason). It it doesn't, we return the status message from template
      case String.match?(template, ~r/.*\.json/) do
        true ->
          %{
            error:
              Map.get(
                conn.assigns.reason,
                :message,
                Phoenix.Controller.status_message_from_template(template)
              )
          }

        false ->
          Phoenix.Controller.json(
            conn,
            %{
              error:
                Map.get(
                  conn.assigns.reason,
                  :message,
                  Phoenix.Controller.status_message_from_template(template)
                )
            }
          )
      end
    else
      Phoenix.Controller.status_message_from_template(template)
    end
  end
```

In this function,
we are retrieving the `content-type` request header
and asserting if it is `json` or not.
If it does,
we return a `json` response.
Otherwise, we do not.

Since users sometimes might not send the `accept` request header
but the `content-type` instead,
Phoenix will assume the template is `*.html`-based.
Hence why we are checking for the template 
format and returning the response accordingly.

## 5.1 Fixing tests

We ought to test these scenarios now!
Open `test/app_web/views/error_view_test.exs`
and add the following piece of code.

```elixir

  alias Phoenix.ConnTest

  test "testing error view with `Accept` header with `application/json` and passing a `.json` template" do
    assigns = %{reason: %{message: "Route not found."}}

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> Map.put(:assigns, assigns)

    conn = %{conn: conn}

    assert Jason.decode!(render_to_string(AppWeb.ErrorView, "404.json", conn)) ==
             %{"error" => "Route not found."}
  end

  test "testing error view with `Content-type` header with `application/json` and passing a `.json` template" do
    assigns = %{reason: %{message: "Route not found."}}

    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> Map.put(:assigns, assigns)

    conn = %{conn: conn}

    assert Jason.decode!(render_to_string(AppWeb.ErrorView, "404.json", conn)) ==
             %{"error" => "Route not found."}
  end

  test "testing error view with `Content-type` header with `application/json` and passing a `.html` template" do
    assigns = %{reason: %{message: "Route not found."}}

    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> Map.put(:assigns, assigns)

    conn = %{conn: conn}

    resp_body = Map.get(render(AppWeb.ErrorView, "404.html", conn), :resp_body)

    assert Jason.decode!(resp_body) == %{"error" => "Route not found."}
  end

  test "testing error view and passing a `.html` template" do
    conn = build_conn()
    conn = %{conn: conn}

    assert render_to_string(AppWeb.ErrorView, "404.html", conn) == "Not Found"
  end
```

If we run `mix test`,
you should see the following output!

```sh
Finished in 1.7 seconds (1.5s async, 0.1s sync)
96 tests, 0 failures
```

And our coverage is back to 100%! 🎉

# 6. Basic `API` Testing Using `cUrl`

At this point we have a working `API` for `items` and `timers`.
We can demonstrate it using `curl` commands in the `Terminal`.

1. Run the `Phoenix` App with the command: `mix s`
2. In a _separate_ `Terminal` window, run the following commands:

## 6.1 _Create_ an `item` via `API` Request

```sh
curl -X POST http://localhost:4000/api/items -H 'Content-Type: application/json' -d '{"text":"My Awesome item text"}'
```
You should expect to see the following result:

```sh
{"id":1}
```

## 6.2 _Read_ the `item` via `API`

Now if you request this `item` using the `id`:

```sh
curl http://localhost:4000/api/items/1
```

You should see: 

```sh
{"id":1,"person_id":0,"status":2,"text":"My Awesome item text"}
```

This tells us that `items` are being created. ✅

## 6.3 Create a `Timer` for your `item`

The route pattern is: `/api/items/:item_id/timers`.
Therefore our `cURL` request is:

```sh
curl -X POST http://localhost:4000/api/items/1/timers -H 'Content-Type: application/json' -d '{"start":"2022-10-28T00:00:00"}'
```

You should see a response similar to the following:

```sh
{"id":1}
```

This is the `timer.id` and informs us that the timer is running. 
You may also create a `timer` without passing a body.
This will create an *ongoing `timer`* 
with a `start` value of the current UTC time.

## 6.4 _Stop_ the `Timer` 

The path to `stop` a timer is `/api/timers/:id`.
Stopping a timer is a simple `PUT` request 
without a body.

```sh
curl -X PUT http://localhost:4000/api/timers/1 -H 'Content-Type: application/json'
```

If the timer with the given `id` was not stopped prior,
you should see a response similar to the following:

```sh
{
  "id": 1,
  "start": "2023-01-11T17:40:44",
  "stop": "2023-01-17T15:43:24"
}
```

Otherwise, an error will surface.

```sh
{
  "code": 403,
  "message": "Timer with the given 'id' has already stopped."
}
```

## 6.5 Updating a `Timer` 

You can update a timer with a specific
`stop` and/or `start` attribute.
This can be done in `/api/items/1/timers/1`
with a `PUT` request.

```sh
curl -X PUT http://localhost:4000/api/items/1/timers/1 -H 'Content-Type: application/json' -d '{"start": "2023-01-11T17:40:44", "stop": "2023-01-11T17:40:45"}'
```

If successful, you will see a response like so.

```sh
{
  "id": 1,
  "start": "2023-01-11T17:40:44",
  "stop": "2023-01-11T17:40:45"
}
```

You might get a `400 - Bad Request` error
if `stop` is before `start`
or the values being passed in the `json` body
are invalid.

```sh
{
  "code": 400,
  "errors": {
    "start": [
      "cannot be later than 'stop'"
    ]
  },
  "message": "Malformed request"
}
```

# 7. Adding `API.Tag`

Having added API controllers for `item` and `timer`,
it's high time to do the same for `tags`!

## 7.1 Updating scope in `router.ex` and tests

Let's start by changing our `lib/app_web/router.ex` file,
the same way we did for `items` and `timers`.

```elixir
  scope "/api", API, as: :api do
    pipe_through [:api, :authOptional]

    resources "/items", Item, only: [:create, :update, :show]

    resources "/items/:item_id/timers", Timer,
      only: [:create, :update, :show, :index]

    put "/timers/:id", Timer, :stop

    resources "/tags", Tag, only: [:create, :update, :show]
  end
```

You might have noticed we've made two changes:

- we've added the `resources "/tags"` line.
We are going to be adding the associated controller 
to handle each operation later.
- added an `as:` property when defining the scope -
`as: :api`.

The latter change pertains to 
[**route helpers**](https://hexdocs.pm/phoenix/routing.html#path-helpers).
Before making this change,
if we run the `mix phx.routes` command,
we get the following result in our terminal.

```sh
      ...
      
      tag_path  GET     /tags                                  AppWeb.TagController :index
      tag_path  GET     /tags/:id/edit                         AppWeb.TagController :edit
      tag_path  GET     /tags/new                              AppWeb.TagController :new
      tag_path  POST    /tags                                  AppWeb.TagController :create
      tag_path  PATCH   /tags/:id                              AppWeb.TagController :update
                PUT     /tags/:id                              AppWeb.TagController :update
      tag_path  DELETE  /tags/:id                              AppWeb.TagController :delete

      item_path  GET     /api/items/:id                         API.Item :show
      item_path  POST    /api/items                             API.Item :create
      item_path  PATCH   /api/items/:id                         API.Item :update
                 PUT     /api/items/:id                         API.Item :update
     timer_path  GET     /api/items/:item_id/timers             API.Timer :index
     timer_path  GET     /api/items/:item_id/timers/:id         API.Timer :show
     timer_path  POST    /api/items/:item_id/timers             API.Timer :create
     timer_path  PATCH   /api/items/:item_id/timers/:id         API.Timer :update
                 PUT     /api/items/:item_id/timers/:id         API.Timer :update
     timer_path  PUT     /api/timers/:id                        API.Timer :stop

    ...
```

These are the routes that we are currently handling
in our application.
However, we will face some issues
if we add a `Tag` controller for our API.
It will **clash with TagController** 
because they share the same path. 💥

`Item` paths can be accessed by route helper
`Routes.item_path(conn, :show, item.id)`,
as shown in the terminal result.

By adding `as: :api` attribute to our scope,
these route helpers will now be prefixed with `"api"`,
making it easier differentiate API and browser calls.

Here's the result after adding 
the aforementioned `as:` attribute to the scope.

```sh 
      ...
      tag_path  GET     /tags                                  AppWeb.TagController :index
      tag_path  GET     /tags/:id/edit                         AppWeb.TagController :edit
      tag_path  GET     /tags/new                              AppWeb.TagController :new
      tag_path  POST    /tags                                  AppWeb.TagController :create
      tag_path  PATCH   /tags/:id                              AppWeb.TagController :update
                PUT     /tags/:id                              AppWeb.TagController :update
      tag_path  DELETE  /tags/:id                              AppWeb.TagController :delete
 api_item_path  GET     /api/items/:id                         API.Item :show
 api_item_path  POST    /api/items                             API.Item :create
 api_item_path  PATCH   /api/items/:id                         API.Item :update
                PUT     /api/items/:id                         API.Item :update
api_timer_path  GET     /api/items/:item_id/timers             API.Timer :index
api_timer_path  GET     /api/items/:item_id/timers/:id         API.Timer :show
api_timer_path  POST    /api/items/:item_id/timers             API.Timer :create
api_timer_path  PATCH   /api/items/:item_id/timers/:id         API.Timer :update
                PUT     /api/items/:item_id/timers/:id         API.Timer :update
api_timer_path  PUT     /api/timers/:id                        API.Timer :stop
      ...
```

Notice that the route helpers 
have changed.
`item_path` now becomes **`api_item_path`**.
The same thing happens with `timer_path`.

By making this change, 
we have broken a handful of tests, 
as they are using these route helpers.
We need to update them!


Update all the route helper calls 
with "`api`" prefixed to fix this.
The files should now look like this:

- [`test/api/item_test.exs`](https://github.com/dwyl/mvp/blob/api_tags-%23256/test/api/item_test.exs)
- [`test/api/timer_test.exs`](https://github.com/dwyl/mvp/blob/27962682ebc4302134a3335133a979739cdaf13e/test/api/timer_test.exs)

## 7.2 Implementing `API.Tag` CRUD operations

Having changed the `router.ex` file 
to call an unimplemented `Tag` controller,
we ought to address that!

Let's start by adding tests of 
what we expect `/tag` CRUD operations to return.

Similarly to `item`,
we want to:
- create a `tag`.
- update a `tag` .
- retrieve a `tag`.

`Tags` receive a `color` parameter,
pertaining to an [hex color code](https://en.wikipedia.org/wiki/Web_colors) - 
e.g. `#FFFFFF`.
If none is passed when created,
a random one is generated.

### 7.2.1 Adding tests

Let's create the test file 
`test/api/tag_test.exs`
and add the following code to it.

```elixir
defmodule API.TagTest do
  use AppWeb.ConnCase
  alias App.Tag

  @create_attrs %{person_id: 42, color: "#FFFFFF", text: "some text"}
  @update_attrs %{person_id: 43, color: "#DDDDDD", text: "some updated text"}
  @invalid_attrs %{person_id: nil, color: nil, text: nil}
  @update_invalid_color %{color: "invalid"}

  describe "show" do
    test "specific tag", %{conn: conn} do
      {:ok, tag} = Tag.create_tag(@create_attrs)
      conn = get(conn, Routes.api_tag_path(conn, :show, tag.id))

      assert conn.status == 200
      assert json_response(conn, 200)["id"] == tag.id
      assert json_response(conn, 200)["text"] == tag.text
    end

    test "not found tag", %{conn: conn} do
      conn = get(conn, Routes.api_tag_path(conn, :show, -1))

      assert conn.status == 404
    end

    test "invalid id (not being an integer)", %{conn: conn} do
      conn = get(conn, Routes.api_tag_path(conn, :show, "invalid"))
      assert conn.status == 400
    end
  end

  describe "create" do
    test "a valid tag", %{conn: conn} do
      conn = post(conn, Routes.api_tag_path(conn, :create, @create_attrs))

      assert conn.status == 200
      assert json_response(conn, 200)["text"] == Map.get(@create_attrs, "text")

      assert json_response(conn, 200)["color"] ==
               Map.get(@create_attrs, "color")

      assert json_response(conn, 200)["person_id"] ==
               Map.get(@create_attrs, "person_id")
    end

    test "an invalid tag", %{conn: conn} do
      conn = post(conn, Routes.api_tag_path(conn, :create, @invalid_attrs))

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end
  end

  describe "update" do
    test "tag with valid attributes", %{conn: conn} do
      {:ok, tag} = Tag.create_tag(@create_attrs)
      conn = put(conn, Routes.api_tag_path(conn, :update, tag.id, @update_attrs))

      assert conn.status == 200
      assert json_response(conn, 200)["text"] == Map.get(@update_attrs, :text)
    end

    test "tag with invalid attributes", %{conn: conn} do
      {:ok, tag} = Tag.create_tag(@create_attrs)
      conn = put(conn, Routes.api_tag_path(conn, :update, tag.id, @invalid_attrs))

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end

    test "tag that doesn't exist", %{conn: conn} do
      {:ok, _tag} = Tag.create_tag(@create_attrs)
      conn = put(conn, Routes.api_tag_path(conn, :update, -1, @update_attrs))

      assert conn.status == 404
    end

    test "a tag with invalid color", %{conn: conn} do
      {:ok, tag} = Tag.create_tag(@create_attrs)
      conn = put(conn, Routes.api_tag_path(conn, :update, tag.id, @update_invalid_color))

      assert conn.status == 400
      assert length(json_response(conn, 400)["errors"]["color"]) > 0
    end
  end
end
```

In a similar fashion to `item` and `timer`,
we are testing the API with the "Happy Path" 
and how it handles receiving invalid attributes.

### 7.2.2 Adding `JSON` encoding and operations to `Tag` schema

In our `lib/app/tag.ex` file resides the `Tag` schema.
To correctly encode and decode it in `JSON` format,
we need to add the `@derive` annotation 
to the schema declaration.

```elixir
@derive {Jason.Encoder, only: [:id, :text, :person_id, :color]}
  schema "tags" do
    field :color, :string
    field :person_id, :integer
    field :text, :string
    many_to_many(:items, Item, join_through: ItemTag)
    timestamps()
  end
```

Additionally, 
we want to have a 
[non-bang function](https://hexdocs.pm/elixir/main/naming-conventions.html#trailing-bang-foo)
to retrieve a tag item,
so we are able to pattern-match
and inform the person using the API 
if the given `id` is invalid 
or no `tag` is found.

For this, add the following line
to `lib/app/tag.ex`'s list of functions.

```elixir
def get_tag(id), do: Repo.get(Tag, id)
```

Lastly, whenever a `tag` is created,
we need to **check if the `color` is correctly formatted**.
For this, we add a `validate_format` 
[validation function](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-validations-and-constraints)
to the `tag` changeset function.

```elixir
def changeset(tag, attrs \\ %{}) do
    tag
    |> cast(attrs, [:person_id, :text, :color])
    |> validate_required([:person_id, :text, :color])
    |> validate_format(:color, ~r/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
    |> unique_constraint([:text, :person_id], name: :tags_text_person_id_index)
  end
```

We are using 
[`regex`](https://en.wikipedia.org/wiki/Regular_expression)
to validate if the input color string
follows the `#XXXXXX` hex color format.

### 7.2.3 Implementing `lib/api/tag.ex`

Now that we have the tests 
and the necessary changes implemented in `lib/app/tag.ex`,
we are ready to create our controller!

Create `lib/api/tag.ex` 
and past the following code.

```elixir
defmodule API.Tag do
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
```

If you have implemented the `API.Item` and `API.Timer` controllers,
you may notice `API.Tag` follows a similar structure:
- we have a `:create` function for creating a `tag`.
- the `:update` function updates a given `tag`.
- the `:show` function retrieves a `tag` with a given `id`.

Each function handles errors
through the changeset validation
we implemented earlier. 
This is evident in the 
`:create` and `:update` functions,
as they return an error if, for example,
a `color` has an invalid format.

And we are all done! 
We can check if the tests pass
by running `mix test`.
Your terminal should yield
the following information.

```sh
Finished in 1.7 seconds (1.6s async, 0.1s sync)
110 tests, 0 failures
```

Congratulations! 🎉
We've just implemented a CRUD `Tag` controller!

## 7.3 Allowing creating `item` with `tags`

When designing an API, 
we ought to take into account
how ["chatty"](https://github.com/dwyl/learn-api-design#avoid-chattiness-in-your-api)
it can be.
An API is considered **chatty**
if it requires the consumer
to make distinct API calls 
to make a specific action/access a resource.

Reducing chattiness has many advantages,
the main one being 
that **less bandwitch is used**,
as we are reducing the number of requests.
Additionally, it *reduces time wasted*
when making multiple requests.

Currently in our API,
if the user wanted to create an `item` and `tags`,
he would need to make *two requests*:
one to create an `item` 
and another to create `tags`.

We can make this better by 
**allowing the user to pass an array of `tags`**
when creating an `item`.

Let's do this!

### 7.3.1 Adding tests

Let's add our tests first.
We have three important constraints
that require validation before 
creating the `item` and `tags`:

- the `tags` need *to be valid*.
If not, inform the user.
- if any `tag` already exists for the given person,
inform the user.
- the `item` needs to be valid.

We want all of these concerns to be validated
before creating an `item`, 
the `tags`
and associating them.

With this in mind, 
let's first start 
by creating the tests needed to cover these scenarios.

We are going to be making changes
in the `:create` function of
`lib/api/item.ex`.

Therefore, open `test/api/item_test.exs` 
and add the following tests
under the `describe "create"` test suite.

```elixir
    @tag_text "tag text"
    @create_attrs %{person_id: 42, status: 0, text: "some text"}
    @create_attrs_with_tags %{person_id: 42, status: 0, text: "some text", tags: [%{text: @tag_text}]}
    @create_attrs_with_invalid_tags %{person_id: 42, status: 0, text: "some text", tags: [%{invalid: ""}]}

    test "a valid item with tags", %{conn: conn} do
      conn = post(conn, Routes.api_item_path(conn, :create, @create_attrs_with_tags))
      assert json_response(conn, 200)
    end

    test "a valid item with tag that already exists", %{conn: conn} do
      conn = post(conn, Routes.api_tag_path(conn, :create, %{text: @tag_text, person_id: @create_attrs_with_tags.person_id}))
      conn = post(conn, Routes.api_item_path(conn, :create, @create_attrs_with_tags))

      assert json_response(conn, 400)
      assert json_response(conn, 400)["message"] =~ "already exists"
    end

    test "a valid item with an invalid tag", %{conn: conn} do
      conn = post(conn, Routes.api_item_path(conn, :create, @create_attrs_with_invalid_tags))

      assert json_response(conn, 400)
      assert length(json_response(conn, 400)["errors"]["text"]) > 0
    end
```

e.g.
[`test/api/item_test.exs`](https://github.com/dwyl/mvp/blob/4c568a0659df6f3047536dfea52ffb53806e1c9e/test/api/item_test.exs)

Each test pertains to the 
constraints we've mentioned earlier.

In addition to this, 
we are going to need a function
to **list the tags text from a person that are already in the database**.
We are going to be using this function
to *compare the given tags*
with the ones that already exist in the database.

For this, 
open `test/app/tag_test.exs`
and add the following piece of code.

```elixir
  describe "List tags" do
    @valid_attrs %{text: "tag1", person_id: 1, color: "#FCA5A5"}

    test "list_person_tags_text/0 returns the tags texts" do
      {:ok, tag} = Tag.create_tag(@valid_attrs)
      tags_text_array = Tag.list_person_tags_text(@valid_attrs.person_id)
      assert length(tags_text_array) == 1
      assert Enum.at(tags_text_array, 0) == @valid_attrs.text
    end
  end
```

We are going to be implementing
the `list_person_tags_text/0` shortly.
This function will list the text of all the tags
for a given `person_id`.

Now that we got the tests added,
it's time for us to start implementing!

### 7.3.2 Implementing `list_person_tags_text/0`

Let's start by 
implementing `list_person_tags_text/0`.
Head over to `lib/app/tag.ex`
and add:

```elixir
  def list_person_tags_text(person_id) do
    Tag
    |> where(person_id: ^person_id)
    |> order_by(:text)
    |> select([t], t.text)
    |> Repo.all()
  end
```

This will return an array of tag texts
pertaining to the given `person_id`.

This function will be used in the next section.

### 7.3.3 Updating `:create` in `lib/api/item.ex`

Now it's time for the bread and butter of this feature!
We are going to be making some changes
in `lib/api/item.ex`.

Let's break down how we are going to implement this.

We want the `item` to be valid,
each `tag` to be valid,
and each `tag` unique (meaning it doesn't already exist).

Open `lib/api/item.ex`,
locate the `create` function.
We are going to be implementing
the following structure.

```elixir
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
         {:ok, tag_changeset_array} <- invalid_tags_from_params_array(tag_parameters_array, item_attrs.person_id),
         {:ok, nil} <- tags_that_already_exist(tag_parameters_array, item_attrs.person_id)
      do

      # Creating item and tags and responding to the user with the newly created `id`.

    else
      
      # Handle any errors

    end
  end
```

We are using a 
[`with` control structure statement](https://www.openmymind.net/Elixirs-With-Statement/).
Using `with` is *super useful* 
when we might use nested `case` statements
or in situations that cannot cleanly be piped together.
This is great since we are doing multiple validations
and we want to handle errors gracefully 
if any of the validations fail.

With `with` statements, 
each expression is executed.
If all "pattern-match" as described above,
the user will create the `item` and `tag` 
and respond with a success message.

Otherwise, we can "pattern-match"
any errors in the `else` statement,
which can be derived from any of the three
expressions being evaluated inside `with`.

You might have noticed we are evaluating three expressions:
- **`true <- item_changeset.valid?`**, 
which uses the `item_changeset` to check if the passed attributes are valid.
- **`{:ok, tag_changeset_array} <- invalid_tags_from_params_array(tag_parameters_array, item_attrs.person_id)`**,
which calls `invalid_tags_from_params_array/2` which,
in turn, checks if any of the tags 
passed in the request are invalid.
It returns an array of `tag` changesets if every `tag` is valid.
- **`{:ok, nil} <- tags_that_already_exist(tag_parameters_array, item_attrs.person_id)`**,
which calls `tags_that_already_exist/2` which, 
in turn, check if any of the passed tags
already exists in the database.
`nil` is returned is none of the `tags` exists in the database.

Let's implement these two validating functions!

#### 7.3.3.1 Creating `tag` validating functions

Let's start with `invalid_tags_from_params_array/2`.
In `lib/api/item.ex`, 
add the next private function.

```elixir
  defp invalid_tags_from_params_array(tag_parameters_array, person_id) do

    tag_changeset_array = Enum.map(tag_parameters_array, fn tag_params ->
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
```

In this function, we receive the `person_id` 
and an array of tag parameters 
(originated from the request body).
We are converting each `tag` param object in the array
to a **changeset**.
This will allow us to check if each param is valid or not.

We *then* return the first invalid tag.
If none is found, we return the `tag` changeset array.

The reason we return a `tag` changeset array
if every `tag` is valid
is to later use it when creating the `item` and `tags` 
and associating the latter with the former 
by calling `create_item_with_tags/1` 
(located in `lib/app/tag.ex`).

Let's implement the other function - 
`tags_that_already_exist/2`.

In the same file `lib/api/item.ex`:

```elixir
  defp tags_that_already_exist(tag_parameters_array, person_id) do
    if(length(tag_parameters_array) != 0) do

      # Retrieve tags texts from database
      db_tags_text = Tag.list_person_tags_text(person_id)
      tag_text_array = Enum.map(tag_parameters_array, fn tag -> Map.get(tag, "text", nil) end)

      # Return first tag that already exists in database. If none is found, return nil
      case Enum.find(db_tags_text, fn x -> Enum.member?(tag_text_array, x) end) do
        nil -> {:ok, nil}
        tag -> {:tag_already_exists, tag}
      end

    else
      {:ok, nil}
    end
  end
```

In this private function 
we *fetch the tags from database* from the given `person_id`
and check if any of the request `tags` 
that were passed in the request 
*already exist in the database*.

If one is found, it is returned as an error.
If not, `nil` is returned, 
meaning the passed `tags` are unique to the `person_id`.

#### 7.3.3.2 Finishing up `lib/api/item.ex`'s `create` function

Now that we know the possible returns
each function used in the `with` expression,
we can implement the rest of the function.

Check out the final version of this function,
in `lib/api/item.ex`.

```elixir
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
         {:ok, tag_changeset_array} <- invalid_tags_from_params_array(tag_parameters_array, item_attrs.person_id),
         {:ok, nil} <- tags_that_already_exist(tag_parameters_array, item_attrs.person_id)
      do

      # Creating item and tags and associate tags to item
      attrs = Map.put(item_attrs, :tags, tag_changeset_array)
      {:ok, %{model: item, version: _version}} = Item.create_item_with_tags(attrs)

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
        errors = make_changeset_errors_readable(tag_changeset) |> Map.put(:message, "At least one of the tags is malformed.")

        json(
          conn |> put_status(400),
          errors
        )
    end
  end
```

If all validations are successfully met,
we *use* the `tag` changeset array
so we can create the `item`, `tags`
and associate them
by calling `Item.create_item_with_tags/1` function
in `lib/app/item.ex`.

After this, we return the `id` of the created `item`.

```elixir
    # Creating item and tags and associate tags to item
    attrs = Map.put(item_attrs, :tags, tag_changeset_array)
    {:ok, %{model: item, version: _version}} = Item.create_item_with_tags(attrs)

    # Return `id` of created item
    id_item = Map.take(item, [:id])
    json(conn, id_item)
```

And lastly, 
if these validations in the `with` statement
are not correctly matched,
we pattern-match the possible return scenarios.

```elixir
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
        errors = make_changeset_errors_readable(tag_changeset) |> Map.put(:message, "At least one of the tags is malformed.")

        json(
          conn |> put_status(400),
          errors
        )
```

If `false` is returned, 
it's because `item_changeset.valid?` returns as such.

If `{:tag_already_exists, tag}` is returned,
it's because `tags_that_already_exist/2`
returns the error and the `tag` text that already exists.

If `{:invalid_tag, tag_changeset}` is returned,
it means `invalid_tags_from_params_array/2` 
returned the error and the `tag` changeset that is invalid.

In **all of these scenarios**,
an error is returned to the user
and a meaningful error message is created.

And you are done! 🎉

You've just *extended* the feature of 
creating an `item` by allowing the user to 
*also* add the `tag` array, if he so wishes.

If you run `mix test`,
all tests should pass!

```sh
Finished in 1.9 seconds (1.7s async, 0.1s sync)
114 tests, 1 failure

Randomized with seed 907513
```


## 7.3 Fetching items with embedded tags

Now that people can create `items` with `tags`,
we can apply the same logic 
and *allow the person to fetch `items` with the associated `tags`*.

We can use **query parameters**
to know if the user wants to embed `tags` or not.
By limiting fields returned by the API,
we are
[following good `RESTful` practices](https://github.com/dwyl/learn-api-design#use-query-parameters-to-filter-sort-or-search-resources).

Luckily, implementing this feature is quite simple!
Let's roll! 🍣

### 7.3.1 Adding tests

Let's add our tests first.
We want the user to pass a *query param*
named `embed` with a value of `"tags"`
so the API returns the `item` with the associated `tags`.

Inside `test/app/item_test.exs`, 
add the following test.

```elixir
    test "get_item/2 returns the item with given id with tags" do
      {:ok, %{model: item, version: _version}} = Item.create_item(@valid_attrs)

      tags = Map.get(Item.get_item(item.id, true), :tags)

      assert Item.get_item(item.id, true).text == item.text
      assert not is_nil(tags)
    end
```

The function `get_item/1` that is currently
in `lib/app/item.ex` will need to be changed
to return tags according to a second boolean parameter.
We will implement this change shortly.

Let's add the test that will check the `:show` endpoint
and if `tags` are being returned when requested.

Inside `test/api/item_test.exs`,
add the following test.

```elixir
    test "specific item with tags", %{conn: conn} do
      {:ok, %{model: item, version: _version}} = Item.create_item(@create_attrs)
      conn = get(conn, Routes.api_item_path(conn, :show, item.id), %{"embed" => "tags"})

      assert json_response(conn, 200)["id"] == item.id
      assert json_response(conn, 200)["text"] == item.text
      assert not is_nil(json_response(conn, 200)["tags"])
    end
```

We are passing a `embed` query parameter with `tags` value
and expect a return with an array of `tags`.

Now that we have the tests added,
let's implement the needed changes for these to pass!

### 7.3.2 Returning `item` with `tags` on endpoint

It's time to implement the changes!
Let's start by changing the function `get_item/1`
in `lib/app/item.ex`.

Change it so it looks like the following.

```elixir
  def get_item(id, preload_tags \\ false ) do
    item = Item
    |> Repo.get(id)

    if(preload_tags == true) do
      item |> Repo.preload(tags: from(t in Tag, order_by: t.text))
    else
      item
    end
  end
```

The user can now send a second parameter 
(which is `false` by default)
detailing if we want to fetch the `item` 
with `tags` preloaded.

We are also going to change how to encode the schema.
Change the `@derive` annotation to the following.

```elixir
  @derive {Jason.Encoder, except: [:__meta__, :__struct__, :timer, :inserted_at, :updated_at]}
  schema "items" do
    field :person_id, :integer
    field :status, :integer
    field :text, :string

    has_many :timer, Timer
    many_to_many(:tags, Tag, join_through: ItemTag, on_replace: :delete)

    timestamps()
  end
```

We are now encoding *all the fields*
except those that are specified.

Now let's *use* this changed function
in the `:show` endpoint of `/items`.

In `lib/api/item.ex`,
change `show/2` to the following.

```elixir
  def show(conn, %{"id" => id} = params) do

    embed = Map.get(params, "embed", "")

    case Integer.parse(id) do
      # ID is an integer
      {id, _float} ->
        retrieve_tags = embed =~ "tag"
        case Item.get_item(id, retrieve_tags) do
          nil ->
            errors = %{
              code: 404,
              message: "No item found with the given \'id\'."
            }

            json(conn |> put_status(404), errors)

          item ->
            if retrieve_tags do
              json(conn, item)
            else
              # Since tags is Ecto.Association.NotLoaded, we have to remove it.
              # By removing it, the object is no longer an Item struct, hence why encoding fails (@derive  no longer applies).
              # We need to remove the rest of the unwanted fields from the "now-map" object.
              #
              # Jason.Encode should do this instead of removing here.
              item = Map.drop(item, [:tags, :timer, :__meta__, :__struct__, :inserted_at, :updated_at])
              json(conn, item)
            end
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
```

We've retrieved the `embed` query parameter
and check if it has a value of `"tag"`.
Depending on whether the person wants `tags` or not,
the result is returned normally.

### 7.3.3 A note about `Jason` encoding

There is another small change
we ought to make.
Since we changed the `@derive` annotation,
the `update/2` function, after updating,
retrieves the `item` and *tries* to encode
`tags`.

If you run `mix test` 
or try to update an item (`PUT /items/:id`),
you will see an error pop up in the terminal.

```sh
     ** (RuntimeError) cannot encode association :tags from App.Item to JSON because the association was not loaded.
     
     You can either preload the association:
     
         Repo.preload(App.Item, :tags)
     
     Or choose to not encode the association when converting the struct to JSON by explicitly listing the JSON fields in your schema:
     
         defmodule App.Item do
           # ...
     
           @derive {Jason.Encoder, only: [:name, :title, ...]}
           schema ... do
     
```

`Jason.Encoder` expects `tags` to be loaded.
However, they are not *preloaded by default*.
The `item` after being updated and returned to the API controller
looks like so:

```elixir
item #=> %App.Item{
  __meta__: #Ecto.Schema.Metadata<:loaded, "items">,
  id: 1,
  person_id: 42,
  status: 0,
  text: "some updated text",
  timer: #Ecto.Association.NotLoaded<association :timer is not loaded>,
  tags: #Ecto.Association.NotLoaded<association :tags is not loaded>,
  inserted_at: ~N[2023-01-26 16:19:29],
  updated_at: ~N[2023-01-26 16:19:30]
}
```

Notice how `:tags` nor `:timer` are not loaded.
`Jason.Encoder` doesn't know how to encode this in a `json` format.

This is why we **also need to add the following line**...

`Map.drop(item, [:tags, :timer, :__meta__, :__struct__, :inserted_at, :updated_at])` 

... to the `update/2` function, like so:

```elixir
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
            item = Map.drop(item, [:tags, :timer, :__meta__, :__struct__, :inserted_at, :updated_at])
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
```

e.g.
[`lib/api/item`](https://github.com/dwyl/mvp/blob/a7a234479467e6c83bd837ca74a2f50433e992df/lib/api/item.ex)

Because `tags` is not loaded, 
we **remove it**.
But by removing this field,
the object *is no longer an `Item` struct*,
so `Jason` doesn't know how to serialize `__meta__` or `__struct__`.

**This is why we remove the detailed fields whenever `tags` are not loaded.**

After all of these changes, 
if you run `mix test`,
all tests should run properly!

Congratulations, 
now the person using the API
can *choose* to retrieve an `item` with `tags` or not!



# Done! ✅

This document is going to be expanded
as development continues.
So if you're reading this, it's because that's all we currently have!

If you found it interesting, 
please let us know by starring the repo on GitHub! ⭐

<br />

[![HitCount](https://hits.dwyl.com/dwyl/app-mvp-api.svg)](https://hits.dwyl.com/dwyl/app-mvp)
