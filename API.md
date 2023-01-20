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
- [7. _Advanced/Automated_ `API` Testing Using `Hoppscotch`](#7-advancedautomated-api-testing-using-hoppscotch)
  - [7.1 Using `Hoppscotch`](#71-using-hoppscotch)
  - [7.2 Integration with `Github Actions` with `Hoppscotch CLI`](#72-integration-with-github-actions-with-hoppscotch-cli)
- [7.2.1 Changing the workflow `.yml` file](#721-changing-the-workflow-yml-file)
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

# 5.1 Fixing tests

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

# 7. _Advanced/Automated_ `API` Testing Using `Hoppscotch`

API testing is a crucial part of the API development lifecycle.
Incorporating tests will allow us 
to avoid regressions 
and make sure our API performs 
the way it's supposed to.
In other words,
the person using the API
*expects* consistent responses to their requests.

Integrating this into a 
[CI pipeline](https://en.wikipedia.org/wiki/Continuous_integration)
automates this process 
and helps avoiding unintentional breaking changes.

We are going to be using 
[`Hoppscotch`](https://github.com/hoppscotch/hoppscotch).
This is an open-source tool 
similar to [Postman](https://www.postman.com/)
which allow us to make requests, 
organize them and create test suites.

## 7.1 Using `Hoppscotch`

`Hoppscotch` can be accessed in https://hoppscotch.io.
In here, you will see an UI similar to the following.

<img width="1528" alt="hoppscotch_ui" src="https://user-images.githubusercontent.com/17494745/213747493-5a59e18a-af3d-4a7e-91b2-a056086d4530.png">

You won't have any requests configured.
To use our **collection** of requests,
you can import it. 
Check the following steps to import 
the `JSON` file in [`.hoppscotch/MVP.json`](./.hoppscotch/MVP.json).

<img width="49%" alt="import1" src="https://user-images.githubusercontent.com/17494745/213747810-d2c0ba75-a7a2-4b98-a5b0-abd17c079faf.png">
<img width="49%" alt="import2" src="https://user-images.githubusercontent.com/17494745/213747822-d855450a-71e1-40ef-b0ab-600b20587238.png">

After importing the collection,
the requests and possible responses are made available.
If you open the `MVP` and subsequent `Items` folders,
you will see a list of possible requests.

<img width="1456" alt="items" src="https://user-images.githubusercontent.com/17494745/213748576-83653fd9-86e0-4c84-93ca-acd9ab499864.png">


You might notice in the URL
we are using *variables*.
These are **environment variables**.
This is useful to switch 
between development or production environments seamlessly.

If you want to test the API locally,
just import [`.hoppscotch/localhost.json`](./.hoppscotch/localhost.json).

<img width="32%" alt="env1" src="https://user-images.githubusercontent.com/17494745/213749782-99edcf6c-0922-473e-9cb5-0eb61037c296.png">
<img width="32%" alt="env2" src="https://user-images.githubusercontent.com/17494745/213749789-b1c347b7-6b10-4747-a39f-491c450a98ba.png">
<img width="32%" alt="env3" src="https://user-images.githubusercontent.com/17494745/213749786-511bf6cb-a9a0-44eb-8bd5-110c3b47b02b.png">

Now you can start testing the requests!
Start the Phoenix server locally
by running `mix phx.server`.

If you open `MVP, Items` 
and try to `Get Item` (by clicking `Send`),
you will receive a response from the `localhost` server.

<img width="32%" alt="get1" src="https://user-images.githubusercontent.com/17494745/213750744-1946f282-1bdb-4ce9-b4e8-7a1f10f790da.png">
<img width="32%" alt="get2" src="https://user-images.githubusercontent.com/17494745/213750736-ffe3fd6f-b668-4b45-af25-51653daca286.png">
<img width="32%" alt="get3" src="https://user-images.githubusercontent.com/17494745/213750742-f4e3f504-7f85-4d4c-80f5-58401c177335.png">

Depending if the `item` with `id=1` 
(which is defined in the *env variable* `item_id`
in the `localhost` environment),
you will receive a successful response
or an error, detailing the error
that the item was not found with the given `id`.

You can create **tests** for each request,
asserting the response object and HTTP code.
You can do so by clicking the `Tests` tab.

<img width="1456" alt="test" src="https://user-images.githubusercontent.com/17494745/213751271-13f71098-d3eb-4fbc-bcb6-1f5ccc30bcd3.png">

These tests are important to validate 
the expected response of the API.
For further information 
on how you can test the response in each request,
please visit their documentation at
https://docs.hoppscotch.io/features/tests.

## 7.2 Integration with `Github Actions` with `Hoppscotch CLI`

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

With `hopps` (Hoppscotch CLI),
we will be able to run the collection of requests
and its tests in a command-line environment. 

To run the tests inside a command-line interface,
we are going to need two files:
- **environment file**, 
a `json` file with each env variable as key
and its referring value.
For an example, 
check the 
[`.hoppscotch/localhost.json` file](./.hoppscotch/localhost.json).
- **collection file**, 
the `json` file with all the requests.
It is the one you imported earlier.
You can export it the same way you imported it.
For an example, 
check the 
[`.hoppscotch/MVP.json` file](./.hoppscotch/MVP.json).

These files 
will need to be pushed into the git repo.
The CI will need access to these files
to run `hopps` commands.

In the case of our application,
for the tests to run properly, 
we need some bootstrap data 
so each request runs successfully.
For this, 
we also added a 
[`.hoppscotch/api_test_mock_data.sql`](.hoppscotch/api_test_mock_data.sql)
`SQL` script file that will insert some mock data.

# 7.2.1 Changing the workflow `.yml` file

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

    - name: Run mix ecto.create
      run: mix ecto.create

    - name: Run ecto.migrate
      run: mix ecto.migrate

    - name: Bootstrap Postgres DB with data
      run: psql -h localhost -p 5432 -d app_dev -U postgres -f ./.hoppscotch/api_test_mock_data.sql

      env:
        POSTGRES_HOST: localhost
        POSTGRES_PORT: 5432
        PGPASSWORD: postgres

    - name: Running server and Hoppscotch Tests
      run: mix phx.server & sleep 5 && hopp test -e ./.hoppscotch/envs.json ./.hoppscotch/MVP.json
```

Let's breakdown what we just added.
We are running this job in a 
[service container](https://docs.github.com/en/actions/using-containerized-services/about-service-containers)
that includes a PostgreSQL database -
similarly to the existent `build` job.

We then install the `Hoppscotch CLI` 
by running `npm i -g @hoppscotch/cli`.

We then run `mix ecto.create` 
and `ecto.migrate` 
to create and setup the database.

After this, 
we *boostrap* the database with 
`psql -h localhost -p 5432 -d app_dev -U postgres -f ./.hoppscotch/api_test_mock_data.sql`.
This command ([`psql`](https://www.postgresql.org/docs/current/app-psql.html))
allows us to connect to the PostgreSQL database
and execute the `.hoppscotch/api_test_mock_data.sql` script,
which inserts data for the tests to run.


At last,
we run the API by running `mix phx.server`
and execute `hopp test -e ./.hoppscotch/localhost.json ./.hoppscotch/MVP.json`.
This `hopp` command takes the environment file
and the collections file
and executes its tests.
You might notice we are using `sleep 5`.
This is because we want the `hopps` 
command to be executed 
after `mix phx.server` finishes initializing.

And you should be done!
When running `hopps test`,
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

If one test fails, the whole build fails, as well.


# Done! ✅

This document is going to be expanded
as development continues.
So if you're reading this, it's because that's all we currently have!

If you found it interesting, 
please let us know by starring the repo on GitHub! ⭐

<br />

[![HitCount](https://hits.dwyl.com/dwyl/app-mvp-api.svg)](https://hits.dwyl.com/dwyl/app-mvp)