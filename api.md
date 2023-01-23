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
- [8. _Advanced/Automated_ `API` Testing Using `Hoppscotch`](#8-advancedautomated-api-testing-using-hoppscotch)
  - [8.0 `Hoppscotch` Setup](#80-hoppscotch-setup)
  - [8.1 Using `Hoppscotch`](#81-using-hoppscotch)
  - [8.2 Integration with `Github Actions` with `Hoppscotch CLI`](#82-integration-with-github-actions-with-hoppscotch-cli)
    - [8.2.1 Changing the workflow `.yml` file](#821-changing-the-workflow-yml-file)
    - [8.2.2 Changing the `priv/repo/seeds.exs` file](#822-changing-the-privreposeedsexs-file)
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
add the following funciton
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

### 7.2 Implementing `API.Tag` CRUD operations

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

#### 7.2.1 Adding tests

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

#### 7.2.2 Adding `JSON` encoding and operations to `Tag` schema

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

#### 7.2.3 Implementing `lib/api/tag.ex`

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

# 8. _Advanced/Automated_ `API` Testing Using `Hoppscotch`

`API` testing is an essential part 
of the development lifecycle.
Incorporating tests will allow us 
to avoid regressions 
and make sure our `API` performs 
the way it's supposed to.
In other words,
the `person` using the API
*expects* consistent responses to their requests.

Integrating this into a 
[CI pipeline](https://en.wikipedia.org/wiki/Continuous_integration)
automates this process 
and helps avoiding unintentional breaking changes.

We are going to be using 
[`Hoppscotch`](https://github.com/hoppscotch/hoppscotch).
This is an open source tool 
similar to [`Postman`](https://www.postman.com/)
that allow us to make requests, 
organize them and create test suites.

Red more about `Hoppscotch`: 
[hoppscotch.io](https://hoppscotch.io)

## 8.0 `Hoppscotch` Setup

There is no `App` to download, 
but you can run `Hoppscotch` as 
an "installable" [`PWA`](https://web.dev/what-are-pwas/):
![hoppscotch-docs-pwa](https://user-images.githubusercontent.com/194400/213877931-47344cfd-4dd7-491e-b032-9e65dff49ebc.png)

In `Google Chrome` and `Microsoft Edge` 
you will see an icon 
in the Address bar to 
"Install Hoppscotch app": 

<img width="410" alt="image" src="https://user-images.githubusercontent.com/194400/213888160-a1da70c9-bb7e-4d28-b2a7-8a876d1b1d00.png">

That will create what _looks_ like a "Native" App on your `Mac`:

<img width="919" alt="image" src="https://user-images.githubusercontent.com/194400/213888365-3e605407-cd78-44b4-8fb9-3e4c165a4916.png">

Which then opens full-screen an _feels_ `Native`:

<img alt="Hoppscotch PWA Homescreen" src="https://user-images.githubusercontent.com/194400/213877899-9b7c3fde-90cd-4071-a986-f36f150e8708.png">

And you're all set to start testing the `API`. 

> Installing the `PWA` will _significantly_ increase your dev speed 
because you can easily ``+`Tab` between your IDE and `Hoppscotch` 
and not have to hunt for a Tab in your Web Browser. 

You can use `Hoppscotch` anonymously
(without logging in),
without any loss of functionality. 

If you decide to Authenticate
and you don't want to see the noise in the Top Nav,
simply enable "Zen Mode":

![hoppscotch-zen-mode](https://user-images.githubusercontent.com/194400/213877013-0ff9c65d-10dc-4741-aa67-395e9fd6adb7.gif)

With that out of the way, let's get started _using_ `Hoppscotch`!


## 8.1 Using `Hoppscotch`

When you first open `Hoppscotch`,
either in the browser or as a `PWA`,
you will not have anything defined:

![hoppscotch-empty](https://user-images.githubusercontent.com/194400/213889044-0e38256d-0c59-41f0-bbbe-ee54a16583e2.png)


The _first_ thing to do is open an _existing_ collection:

<img alt="hoppscotch-open-collection" src="https://user-images.githubusercontent.com/194400/213888966-3879177b-3c06-47b1-8654-85b9ffe8c8e3.png">

Import from hoppscotch: `/lib/api/MVP.json`

<img alt="hoppscotch-open-local" src="https://user-images.githubusercontent.com/194400/213888968-7d907b9d-7122-4945-a809-cfe0d3476698.png">

Collection imported:

<img  alt="image" src="https://user-images.githubusercontent.com/194400/213888655-ec4be134-c827-44d3-a503-09f760b8a95e.png">

_Next_ you'll need to open environment configuration / variables:

<img alt="hoppscotch-open-environment" src="https://user-images.githubusercontent.com/194400/213889204-ed95f46d-dc60-49cc-85b8-822a1fe22321.png">


![hoppscotch-open-env](https://user-images.githubusercontent.com/194400/213889224-45dd660e-874d-422c-913d-bfdba1052944.png)

When you click on `Localhost`, you will see an `Edit Environment` Modal:

<img alt="image" src="https://user-images.githubusercontent.com/194400/213889517-432b162a-83c9-443c-89a3-47f6f32e1911.png">

**environment variables**
let us switch 
between development or production environments seamlessly.

Even after you have imported the environment configuration file, 
it's not automatically selected: 

<img alt="hoppscotch-environment-not-found" src="https://user-images.githubusercontent.com/194400/213894754-4881aca8-f150-4ac1-a2fe-07cf81758f4a.png">

You need to **_manually_ select `Localhost`**.
With the "Environments" tab selected, click the "Select environment" selector and chose "Localhost":

<img alt="hoppscotch-select-environment-localhost" src="https://user-images.githubusercontent.com/194400/213894854-a847344d-75cb-4290-ba18-b9796a8e9235.png">

Once you've selected the `Localhost` environment, the `<<host>>` placeholder will turn from red to blue:

<img alt="image" src="https://user-images.githubusercontent.com/194400/213894929-8d61dda7-fef3-4fcd-a342-0bfff5d0d953.png">

After importing the collection,
open the `MVP` and `Items` folder,
you will see a list of possible requests.


After importing the collection and environment, it _still_ won't work ...
<img width="1537" alt="image" src="https://user-images.githubusercontent.com/194400/213896708-9c7cd991-0612-497c-9ef6-b9034a92a618.png">

You will see the message: 

**Could not send request**. 
Unable to reach the API endpoint. Check your network <br />connection or select a different interceptor and try again.


These are the available options: 

![image](https://user-images.githubusercontent.com/194400/213896782-b96d97a5-5e42-41ec-b299-e64c77246b79.png)

If you select "Browser extension" it will open the Chrome web store where you can install the extension.

Install the extension. 
Once installed, 
add the the `http://localhost:4000` origin:

<img width="541" alt="add endpoint" src="https://user-images.githubusercontent.com/194400/213896896-83c526f3-baad-4196-b8b0-0389c2e0f55a.png">

Then the presence of the extension will be visible in the Hoppscotch window/UI:

![image](https://user-images.githubusercontent.com/194400/213896932-a8f48f2a-f5ee-47c1-aad6-d9a09cf27b48.png)

<img width="366" alt="image" src="https://user-images.githubusercontent.com/194400/213896635-7c967907-7ad1-4e65-aaf4-5d892fc0f2f1.png">


Now you can start testing the requests!
Start the Phoenix server locally
by running `mix s`

The requests in the collection will _finally_ work:

![image](https://user-images.githubusercontent.com/194400/213897127-c70a5961-1db6-4d1f-a944-cf08a5bf2f86.png)



If you open `MVP, Items` 
and try to `Get Item` (by clicking `Send`),
you will receive a response from the `localhost` server.

<img alt="get1" src="https://user-images.githubusercontent.com/17494745/213750744-1946f282-1bdb-4ce9-b4e8-7a1f10f790da.png">
<img alt="get2" src="https://user-images.githubusercontent.com/17494745/213750736-ffe3fd6f-b668-4b45-af25-51653daca286.png">
<img alt="get3" src="https://user-images.githubusercontent.com/17494745/213750742-f4e3f504-7f85-4d4c-80f5-58401c177335.png">

Depending if the `item` with `id=1` 
(which is defined in the *env variable* `item_id`
in the `localhost` environment),
you will receive a successful response
or an error, detailing the error
that the item was not found with the given `id`.

You can create **tests** for each request,
asserting the response object and HTTP code.
You can do so by clicking the `Tests` tab.

<img alt="test" src="https://user-images.githubusercontent.com/17494745/213751271-13f71098-d3eb-4fbc-bcb6-1f5ccc30bcd3.png">

These tests are important to validate 
the expected response of the API.
For further information 
on how you can test the response in each request,
please visit their documentation at
https://docsapi.io/features/tests.

## 8.2 Integration with `Github Actions` with `Hoppscotch CLI`

These tests can (and should!)
be used in CI pipelines.
To integrate this in our Github Action,
we will need to make some changes to our 
[workflow file](https://docs.github.com/en/actions/using-workflows)
in `.github/worflows/ci.yml`.

We want the [runner](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions#runners)
to be able to *execute* these tests.

For this, we are going to be using 
[**`Hoppscotch CLI`**](https://docs.hoppscotch.io/cli).

With `hopp` (Hoppscotch CLI),
we will be able to run the collection of requests
and its tests in a command-line environment. 

To run the tests inside a command-line interface,
we are going to need two files:
- **environment file**, 
a `json` file with each env variable as key
and its referring value.
For an example, 
check the 
[`lib/api/localhost.json` file](./lib/api/localhost.json).
- **collection file**, 
the `json` file with all the requests.
It is the one you imported earlier.
You can export it the same way you imported it.
For an example, 
check the 
[`/lib/api/MVP.json` file](./lib/api/MVP.json).

These files 
will need to be pushed into the git repo.
The CI will need access to these files
to run `hopp` commands.

In the case of our application,
for the tests to run properly, 
we need some bootstrap data 
so each request runs successfully.
For this, 
we also added a 
[`api_test_mock_data.sql`](lib/api/api_test_mock_data.sql)
`SQL` script file that will insert some mock data.

### 8.2.1 Changing the workflow `.yml` file

It's time to add this API testing step
into our CI workflow!
For this, open `.github/workflows/ci.yml`
and add the following snippet of code
between the `build` and `deploy` jobs.


```yml
  # API Definition testing
  # https://docs.hoppscotch.io/cli 
  api_definition:
    name: API Definition Tests
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:12
        ports: ['5432:5432']
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    strategy:
      matrix:
        otp: ['25.1.2']
        elixir: ['1.14.2']
    steps:
    - uses: actions/checkout@v2
    - name: Set up Elixir
      uses: erlef/setup-beam@v1
      with:
        otp-version: ${{ matrix.otp }}
        elixir-version: ${{ matrix.elixir }} 
    - name: Restore deps and _build cache
      uses: actions/cache@v3
      with:
        path: |
          deps
          _build
        key: deps-${{ runner.os }}-${{ matrix.otp }}-${{ matrix.elixir }}-${{ hashFiles('**/mix.lock') }}
        restore-keys: |
          deps-${{ runner.os }}-${{ matrix.otp }}-${{ matrix.elixir }}
    - name: Install dependencies
      run: mix deps.get

    - name: Install Hoppscotch CLI
      run: npm i -g @hoppscotch/cli

    # Setups database and adds seed data for API definition tests
    - name: Run mix setup
      run: mix ecto.setup
      env:
        MIX_ENV: dev
        AUTH_API_KEY: ${{ secrets.AUTH_API_KEY }}

    - name: Running server and Hoppscotch Tests
      run: mix phx.server & sleep 5 && hopp test -e ./lib/api/localhost.json ./lib/api/MVP.json
```

Let's breakdown what we just added.
We are running this job in a 
[service container](https://docs.github.com/en/actions/using-containerized-services/about-service-containers)
that includes a PostgreSQL database -
similarly to the existent `build` job.

We then install the `Hoppscotch CLI` 
by running `npm i -g @hoppscotch/cli`.

We then run `mix ecto.setup`.
This command creates the database,
runs the migrations
and executes `run priv/repo/seeds.exs`.
The list of commands is present
in the [`mix.exs` file](./mix.exs).

We are going to change the `seeds.exs` 
file to bootstrap the database 
with sample data for the API tests to run.


At last,
we run the API by running `mix phx.server`
and execute `hopp test -e ./lib/api/localhost.json ./lib/api/MVP.json`.
This `hopp` command takes the environment file
and the collections file
and executes its tests.
You might notice we are using `sleep 5`.
This is because we want the `hopp` 
command to be executed 
after `mix phx.server` finishes initializing.

And you should be done!
When running `hopp test`,
you will see the result of each request test.

```sh
↳ API.Item.update/2, at: lib/api/item.ex:65
 400 : Bad Request (0.049 s)
[info] Sent 400 in 4ms
  ✔ Status code is 400
  Ran tests in 0.001 s

Test Cases: 0 failed 31 passed
Test Suites: 0 failed 28 passed
Test Scripts: 0 failed 22 passed
Tests Duration: 0.041 s
```

If one test fails, the whole build fails, as well!

### 8.2.2 Changing the `priv/repo/seeds.exs` file

As we mentioned prior, 
the last thing we need to do is 
to change our `priv/repo/seeds.exs` file
so it adds sample data for the tests to run
when calling `mix ecto.setup`.
Use the following piece of code
and change `seeds.exs` to look as such.


```elixir
if not Envar.is_set?("AUTH_API_KEY") do
  Envar.load(".env")
end

if Mix.env() == :dev do
  App.Item.create_item(%{text: "random text", person_id: 0, status: 2})

  {:ok, _timer} =
    App.Timer.start(%{
      item_id: 1,
      start: "2023-01-19 15:52:00",
      stop: "2023-01-19 15:52:03"
    })

  {:ok, _timer2} =
    App.Timer.start(%{item_id: 1, start: "2023-01-19 15:55:00", stop: nil})
end
```

We are only adding sample data
when the server is being run in `dev` mode.

# Done! ✅

This document is going to be expanded
as development continues.
So if you're reading this, it's because that's all we currently have!

If you found it interesting, 
please let us know by starring the repo on GitHub! ⭐

<br />

[![HitCount](https://hits.dwyl.com/dwyl/app-mvp-api.svg)](https://hits.dwyl.com/dwyl/app-mvp)
