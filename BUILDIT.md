<div align="center">

# Build Log 👩‍💻 
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/dwyl/mvp/ci.yml?label=build&style=flat-square&branch=main)

This is a log 
of the steps taken 
to build the MVP. 🚀 <br />
It took us _hours_ 
to write it,
but you can 
[***speedrun***](https://en.wikipedia.org/wiki/Speedrun)
it in **20 minutes**. 🏁

</div>

> **Note**: we have referenced sections 
> in our more extensive tutorials/examples
> to keep this doc 
> [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself). <br />
> You don't have to follow every step in
> the other tutorials/examples,
> but they are linked in case you get stuck.

In this log we have written the "CRUD" functions first
and _then_ built the UI. <br />
We were able to do this because we had a good idea
of which functions we were going to need. <br />
If you are reading through this
and scratching your head 
wondering where a particular function will be used,
simply scroll down to the UI section
where (_hopefully_) it will all be clear. 

At the end of each step,
remember to run the tests:

```sh
mix test
```

This will help you keep track of where you are
and retrace your steps if something is not working as expected.

We suggest keeping two terminal tabs/windows running
one for the server `mix phx.server` and the other for the tests.
That way you can also see the UI as you progress.

We created a *separate*
document detailing the implementation of the `API`.
Please see: 
[`API.md`](./API.md).

With that in place, let's get building! 

- [Build Log 👩‍💻](#build-log-)
- [1. Create a New `Phoenix` App](#1-create-a-new-phoenix-app)
  - [1.1 Run the `Phoenix` App](#11-run-the-phoenix-app)
  - [1.2 Run the tests:](#12-run-the-tests)
    - [Test Coverage?](#test-coverage)
  - [1.3 Setup `Tailwind`](#13-setup-tailwind)
  - [1.4 Setup `LiveView`](#14-setup-liveview)
  - [1.5 Update `router.ex`](#15-update-routerex)
  - [1.6 Update Tests](#16-update-tests)
  - [1.7 Delete Page-related Files](#17-delete-page-related-files)
- [2. Create Schemas to Store Data](#2-create-schemas-to-store-data)
  - [_Explanation_ of the Schemas](#explanation-of-the-schemas)
    - [`item`](#item)
    - [`timer`](#timer)
  - [2.1 Run Tests!](#21-run-tests)
- [3. Input `items`](#3-input-items)
  - [3.1 Make the `item` Tests Pass](#31-make-the-item-tests-pass)
- [4. Create `Timer`](#4-create-timer)
  - [Make `timer` tests pass](#make-timer-tests-pass)
- [5. `items` with `timers`](#5-items-with-timers)
  - [5.1 Test for `accumulate_item_timers/1`](#51-test-for-accumulate_item_timers1)
  - [5.2 Implement the `accummulate_item_timers/1` function](#52-implement-the-accummulate_item_timers1-function)
  - [5.3 Test for `items_with_timers/1`](#53-test-for-items_with_timers1)
  - [5.4 Implement `items_with_timers/1`](#54-implement-items_with_timers1)
- [6. Add Authentication](#6-add-authentication)
  - [6.1 Add `auth_plug` to `deps`](#61-add-auth_plug-to-deps)
  - [6.2 Get your `AUTH_API_KEY`](#62-get-your-auth_api_key)
  - [6.2 Create Auth Controller](#62-create-auth-controller)
- [7. Create `LiveView` Functions](#7-create-liveview-functions)
  - [7.1 Write `LiveView` Tests](#71-write-liveview-tests)
  - [7.2 Implement the `LiveView` functions](#72-implement-the-liveview-functions)
- [8. Implement the `LiveView` UI Template](#8-implement-the-liveview-ui-template)
  - [8.1 Update the `root` layout/template](#81-update-the-root-layouttemplate)
  - [8.2 Create the `icons` template](#82-create-the-icons-template)
- [9. Update the `LiveView` Template](#9-update-the-liveview-template)
- [10. Filter Items](#10-filter-items)
- [11. Tags](#11-tags)
  - [11.1 Migrations](#111-migrations)
  - [11.2 Schemas](#112-schemas)
  - [11.3 Test tags with Iex](#113-test-tags-with-iex)
  - [11.4 Testing Schemas](#114-testing-schemas)
  - [11.4  Items-Tags association](#114--items-tags-association)
- [12. Editing timers](#12-editing-timers)
  - [12.1 Parsing DateTime strings](#121-parsing-datetime-strings)
  - [12.2 Persisting update in database](#122-persisting-update-in-database)
  - [12.3 Adding event handler in `app_live.ex`](#123-adding-event-handler-in-app_liveex)
  - [12.4 Updating timer changeset list on `timer.ex`](#124-updating-timer-changeset-list-on-timerex)
  - [12.5 Updating the UI](#125-updating-the-ui)
  - [12.6 Updating the tests and going back to 100% coverage](#126-updating-the-tests-and-going-back-to-100-coverage)
- [13. Tracking changes of `items` in database](#13-tracking-changes-of-items-in-database)
  - [13.1 Setting up](#131-setting-up)
  - [13.2 Changing database transactions on `item` insert and update](#132-changing-database-transactions-on-item-insert-and-update)
  - [13.3 Fixing tests](#133-fixing-tests)
  - [13.4 Checking the changes using `DBEaver`](#134-checking-the-changes-using-dbeaver)
- [14. Adding a dashboard to track metrics](#14-adding-a-dashboard-to-track-metrics)
  - [14.1 Adding new `LiveView` page in `/stats`](#141-adding-new-liveview-page-in-stats)
  - [14.2 Fetching counter of `timers` and `items` for each `person`](#142-fetching-counter-of-timers-and-items-for-each-person)
  - [14.3 Building the Stats Page](#143-building-the-stats-page)
  - [14.4 Broadcasting to `stats` channel](#144-broadcasting-to-stats-channel)
  - [14.5 Adding tests](#145-adding-tests)
- [15. `People` in Different Timezones 🌐](#15-people-in-different-timezones-)
  - [15.1 Getting the `person`'s Timezone](#151-getting-the-persons-timezone)
  - [15.2 Changing how the timer datetime is displayed](#152-changing-how-the-timer-datetime-is-displayed)
  - [15.3 Persisting the adjusted timezone](#153-persisting-the-adjusted-timezone)
  - [15.4 Adding test](#154-adding-test)
- [16. `Lists`](#16-lists)
- [17. Reordering `items` Using Drag \& Drop](#17-reordering-items-using-drag--drop)
  - [17.1 `Item` schema changes](#171-item-schema-changes)
  - [16.2 Changing the Item's `position` field in the database](#162-changing-the-items-position-field-in-the-database)
  - [16.3 Return `position` in `items_with_timers` function](#163-return-position-in-items_with_timers-function)
  - [16.4 Implementing drag and drop in `Liveview`](#164-implementing-drag-and-drop-in-liveview)
  - [16.5 Adding unit test](#165-adding-unit-test)
  - [16.6 Check it in action!](#166-check-it-in-action)
- [17. Run the _Finished_ MVP App!](#17-run-the-finished-mvp-app)
  - [17.1 Run the Tests](#171-run-the-tests)
  - [17.2 Run The App](#172-run-the-app)
- [Thanks!](#thanks)


# 1. Create a New `Phoenix` App

Open your terminal and 
**create** a **new `Phoenix` app**
with the following command:

```sh
mix phx.new app --no-mailer --no-dashboard --no-gettext
```

When asked to install the dependencies,
type `Y` and `[Enter]` (_to install everything_).

The MVP won't
send emails,
display dashboards 
or translate to other languages
(sorry). <br />
_All_ of those things 
will be in the _main_ 
[dwyl/**app**](https://github.com/dwyl/app). <br />
We're excluding them here
to reduce complexity/dependencies.

## 1.1 Run the `Phoenix` App

Run the `Phoenix` app with the command:

```sh
cd app
mix phx.server
```

You should see output similar to the following in your terminal:
```sh
Generated app app
[info] Running AppWeb.Endpoint with cowboy 2.9.0 at 127.0.0.1:4000 (http)
[info] Access AppWeb.Endpoint at http://localhost:4000
[debug] Downloading esbuild from https://registry.npmjs.org/esbuild-darwin-64/-/esbuild-darwin-64-0.14.29.tgz
[watch] build finished, watching for changes...
```

That's a good sign, `esbuild` was downloaded
and the assets were compiled successfully.

Visit 
[`localhost:4000`](http://localhost:4000) 
from your browser.

You should see something similar to the following 
(default `Phoenix` homepage):

![phoenix-default-homepage](https://user-images.githubusercontent.com/194400/174807257-34120dc5-723e-4b2c-9e8e-4b6f3aefca14.png)


## 1.2 Run the tests:

To run the tests with 


You should see output similar to:

```sh
...

Finished in 0.1 seconds (0.07s async, 0.07s sync)
3 tests, 0 failures
```

That tells us everything is working as expected. 🚀


### Test Coverage?

If you prefer to see **test coverage** - we certainly do -
then you will need to add a few lines to the 
[`mix.exs`](https://github.com/dwyl/app-mvp/blob/main/mix.exs)
file. You need to do two things: 
*add a [`coveralls.json`](https://github.com/dwyl/app-mvp/blob/main/coveralls.json) 
file (copy the contents)* 
and _change `mix.exs` file according to 
[**`commit #d6ab5ef7c`**](https://github.com/dwyl/app-mvp/pull/90/commits/d6ab5ef7c2be5dcad7d060e782393ae29c94a526)
(add alias in `defp aliases do` list with the `mix c` command)_. 

This is just standard `Phoenix` project setup for us, 
so we don't duplicate any of the steps here. <br />
For more detail, please see:
[Automated Testing](https://github.com/dwyl/phoenix-chat-example#testing-our-app-automated-testing)
in the 
[dwyl/phoenix-chat-example](https://github.com/dwyl/phoenix-chat-example#testing-our-app-automated-testing)
and specifically
[What is _not_ tested?](https://github.com/dwyl/phoenix-chat-example#13-what-is-not-tested)

With that setup, run:

```sh
mix c
```

You should see output similar to the following:

<img width="653" alt="Phoenix tests passing coverage 100%" src="https://user-images.githubusercontent.com/194400/175767439-4f609357-24c0-4975-a3d4-6ed6057bb321.png">


## 1.3 Setup `Tailwind`

With the release of 
[**`Phoenix 1.7`**](https://phoenixframework.org/blog/phoenix-1.7-final-released),
**`Tailwind CSS`** is automatically built-in.
So if you are starting the project with the new
`phx.new` generator,
you don't need to follow any steps.

Otherwise,
please refer to:
[Tailwind in Phoenix](https://github.com/dwyl/learn-tailwind#part-2-tailwind-in-phoenix).
Setting up should only take **`~1 minute`**.

By the end of this step you should have **`Tailwind`** working.
When you visit 
[`localhost:4000`](http://localhost:4000) 
in your browser, 
you should see: 

![hello world tailwind phoenix](https://user-images.githubusercontent.com/194400/174838767-20bf201e-3179-4ff9-8d5d-751295d1d069.png)

If you got stuck in this section,
please retrace the steps
and open an issue:
[learn-tailwind/issues](https://github.com/dwyl/learn-tailwind/issues)

## 1.4 Setup `LiveView`

Create the `lib/app_web/live` directory
and the controller at `lib/app_web/live/app_live.ex`:

```elixir
defmodule AppWeb.AppLive do
  use AppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
```

Create the `lib/app_web/views/app_view.ex` file:

```elixir
defmodule AppWeb.AppView do
  use AppWeb, :view
end
```

Next, create the
**`lib/app_web/live/app_live.html.heex`**
file 
and add the following line of `HTML`:

```html
<h1 class="">LiveView App Page!</h1>
```

Finally, to make the **root layout** simpler, 
open the 
`lib/app_web/templates/layout/root.html.heex`
file and 
update the contents of the `<body>` to:

```html
<body>
  <header>
    <section class="container">
      <h1>App MVP Phoenix</h1>
    </section>
  </header>
  <%= @inner_content %>
</body>
```

## 1.5 Update `router.ex`

Now that you've created the necessary files,
open the router
`lib/app_web/router.ex` 
replace the default route `PageController` controller:

```elixir
get "/", PageController, :index
```

with `AppLive` controller:


```elixir
scope "/", AppWeb do
  pipe_through :browser

  live "/", AppLive
end
```

Now if you refresh the page 
you should see the following:

<img width="1077" alt="liveveiw-page-with-tailwind-style" src="https://user-images.githubusercontent.com/17494745/198072436-71ab8739-e4c7-4cdb-84f0-3803cc2f1fcc.png">

## 1.6 Update Tests

At this point we have made a few changes 
that mean our automated test suite will no longer pass ... 
Run the tests in your command line with the following command:

```sh
mix test
```

You should see the tests fail:

```sh
..

  1) test GET / (AppWeb.PageControllerTest)
     test/app_web/controllers/page_controller_test.exs:4
     Assertion with =~ failed
     code:  assert html_response(conn, 200) =~ "Hello TailWorld!"
     left:  "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"utf-8\">\n    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
     <main class=\"container\">
     <h1 class=\"text-6xl text-center\">LiveView App Page!</h1>\n</main></div>
     </body>\n</html>"
     right: "Hello TailWorld!"
     stacktrace:
       test/app_web/controllers/page_controller_test.exs:6: (test)

Finished in 0.1 seconds (0.06s async, 0.1s sync)
3 tests, 1 failure
```

Create a new directory: `test/app_web/live`

Then create the file: 
`test/app_web/live/app_live_test.exs`

With the following content:

```elixir
defmodule AppWeb.AppLiveTest do
  use AppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "LiveView App Page!"
  end
end
```

Save the file, 
delete the `test/app_web/controllers/page_controller_test.exs`
(it has the failing test on an unused component)
and re-run the tests: `mix test`

You should see output similar to the following:

```sh
Generated app app
The database for App.Repo has been dropped
...

Finished in 0.1 seconds (0.08s async, 0.1s sync)
3 tests, 0 failures

Randomized with seed 796477
```

## 1.7 Delete Page-related Files

Since we won't be using the `page` in our App, 
we can delete the default files created by `Phoenix`:

```sh
lib/app_web/views/page_view.ex
lib/app_web/controllers/page_controller.ex
lib/app_web/templates/page/index.html.heex
```

With those files deleted,
our **`Phoenix + LiveView`** project 
is now fully setup
and ready to start _building_!

<!-- temp commenting this out as it's a bit of a side-track ...

### Side Note: _Data_-first Design 💡

There are _several_ ways to design and build Apps.
One of the popular approaches 
is to start by trying to define the UI/UX
e.g: by creating a wireframe in **`Figma`**.
This makes an implicit assumption
about how we expect people to interact
with the App.
We often build Apps UI/UX-first
because moving boxes/buttons & text 
around in a low-fidelity wireframe
is a _lot_ cheaper/easier/faster
than writing code. 
However when we are doing an _exploratory_
MVP tightly defining the UI/UX
can create regidity too early.
Another approach is to think about the 
**`data`** we want to capture
and how we may want 
to _transform_ that **`data`**.

For a _much_ more elequent
explanation of why **`data`** first
development makese sense,
watch
"Make Data Structures" 
by Richard Feldman:
https://youtu.be/x1FU3e0sT1I
You don't need to know _any_ `Elm`
to watch this talk.

-->

# 2. Create Schemas to Store Data

Create database schemas 
to store the data
with the following 
[**`mix phx.gen.schema`**](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html)
commands:

```sh
mix phx.gen.schema Item items person_id:integer status:integer text:string
mix phx.gen.schema Timer timers item_id:references:items start:naive_datetime stop:naive_datetime
```

At the end of this step,
we have the following database
[Entity Relationship Diagram](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model)
(ERD):

![mvp-erd-items-timers](https://user-images.githubusercontent.com/194400/183075195-c1b50232-5988-47cb-ad18-47dfd4c0bcc3.png)


We created **2 database tables**;
`items`  and `timers`.
Let's run through them.

## _Explanation_ of the Schemas

This is a quick breakdown of the schemas created above:

### `item`

An `item` is the most basic unit of content.
An **`item`** is just a **`String`** of **`text`**.
Later we will be able to 
e.g: a "note", "task", "reminder", etc.
The name **`item`** is **_deliberately_ generic**
as it maintains complete flexibility 
for what we are building later on.

+ `id`: `Int` - the auto-incrementing `id`.
+ `text`: `Binary` (_encrypted_) - the free text you want to capture.
+ `person_id`: `Integer` 
   the "owner" of the `item`)
+ `status`: `Integer`  the `status` of the `item` 
  e.g: **`3`** = 
  [**`active`**](https://github.com/dwyl/statuses/blob/176acda7ea4a177da90011100ad2758bd90415b1/lib/statuses.ex#L24-L28)
+ `inserted_at`: `NaiveDateTime` - created/managed by `Phoenix`
+ `updated_at`: `NaiveDateTime`


<!--
> **Note**: The keen-eyed observer 
(with PostgreSQL experience)
will have noticed that `items.person_id` is an `Integer` (`int4`) data type.
This means we are _limited_ to **`2147483647` people** using the MVP.
See:
[/datatype-numeric.html](https://www.postgresql.org/docs/current/datatype-numeric.html)
We aren't expecting more than 
***2 billion*** people to use the MVP. 😜
-->

### `timer`

A `timer` is associated with an `item`
to track how long it takes to ***complete***.

  + `id`: `Int`
  + `item_id` (Foreign Key `item.id`)
  + `start`: `NaiveDateTime` - start time for the timer
  + `stop`: `NaiveDateTime` - stop time for the timer
  + `inserted_at`: `NaiveDateTime` - record insertion time
  + `updated_at`: `NaiveDateTime`

An `item` can have zero or more `timers`.

Each time an `item` (`task`) is worked on
a **_new_ `timer`** is created/started (_and stopped_).
Meaning a `person` can split the completion 
of an `item` (`task`) across multiple sessions.
That allows us to get a running total
of the amount of time that has
been taken.

<!--
> **Note**: 
> The point of having a distinct `start` and `stop`
instead of just reusing the `inserted_at`
and `updated_at` is simple:
it will allow people to set their timer `start` and/or `stop`
to a different time than the automatic one. 
But they will not be able to update the `inserted_at` or `updated_at`
so we always know when the record was created/updated.
-->



<br />

## 2.1 Run Tests!

Once we've created the required schemas,
several new files are created.
If we run the tests with coverage:

```sh
mix c
```

We note that the test coverage 
has dropped considerably:

```sh
Finished in 0.1 seconds (0.08s async, 0.09s sync)
3 tests, 0 failures

----------------
COV    FILE                                        LINES RELEVANT   MISSED
  0.0% lib/app/item.ex                                19        2        2
  0.0% lib/app/timer.ex                               20        2        2
100.0% lib/app_web/live/app_live.ex                   11        2        0
100.0% lib/app_web/router.ex                          18        2        0
100.0% lib/app_web/views/error_view.ex                16        1        0
[TOTAL]  38.5%
----------------
```

Specifically the files:
`lib/app/item.ex`
and 
`lib/app/timer.ex`
have **_zero_ test coverage**. 

We will address this test coverage shortfall in the next section.
Yes, we _know_ this is not 
["TDD"](https://github.com/dwyl/learn-tdd#what-is-tdd)
because we aren't writing the tests _first_.
But by creating database schemas,
we have a scaffold 
for the next stage.
See: https://en.wikipedia.org/wiki/Scaffold_(programming)

<br />

# 3. Input `items`

We're going to 


Create the directory `test/app`
and file:
`test/app/item_test.exs`
with the following code:

```elixir
defmodule App.ItemTest do
  use App.DataCase
  alias App.{Item, Timer}

  describe "items" do
    @valid_attrs %{text: "some text", person_id: 1, status: 2}
    @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    test "get_item!/1 returns the item with given id" do
      {:ok, item} = Item.create_item(@valid_attrs)
      assert Item.get_item!(item.id).text == item.text
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Item.create_item(@valid_attrs)

      assert item.text == "some text"

      inserted_item = List.first(Item.list_items())
      assert inserted_item.text == @valid_attrs.text
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Item.create_item(@invalid_attrs)
    end

    test "list_items/0 returns a list of items stored in the DB" do
      {:ok, _item1} = Item.create_item(@valid_attrs)
      {:ok, _item2} = Item.create_item(@valid_attrs)

      assert Enum.count(Item.list_items()) == 2
    end

    test "update_item/2 with valid data updates the item" do
      {:ok, item} = Item.create_item(@valid_attrs)

      assert {:ok, %Item{} = item} = Item.update_item(item, @update_attrs)
      assert item.text == "some updated text"
    end
  end
end
```

The first five tests are basic 
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete).

If you run these tests:
```sh
mix test test/app/item_test.exs
```

You will see all the testes _fail_.
This is expected as the code is not there yet!



## 3.1 Make the `item` Tests Pass

Open the 
`lib/app/item.ex` 
file and replace the contents 
with the following code:


```elixir
defmodule App.Item do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias App.Repo
  alias __MODULE__

  schema "items" do
    field :person_id, :integer
    field :status, :integer
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:person_id, :status, :text])
    |> validate_required([:text])
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{text: "Learn LiveView"})
      {:ok, %Item{}}

      iex> create_item(%{text: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs) do
    %Item{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Returns the list of items where the status is different to "deleted"

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Item
    |> order_by(desc: :inserted_at)
    |> where([i], is_nil(i.status) or i.status != 6)
    |> Repo.all()
  end

  @doc """
  Updates an `item`.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  # soft delete an item:
  def delete_item(id) do
    get_item!(id)
    |> Item.changeset(%{status: 6})
    |> Repo.update()
  end
end
```

Once you have saved the file, re-run the tests.
They should now pass.


# 4. Create `Timer`

Open the `test/app/timer_test.exs` file and add the following tests:

```elixir
defmodule App.TimerTest do
  use App.DataCase
  alias App.{Item, Timer}

  describe "timers" do
    @valid_item_attrs %{text: "some text", person_id: 1}

    test "Timer.start/1 returns timer that has been started" do
      {:ok, item} = Item.create_item(@valid_item_attrs)
      assert Item.get_item!(item.id).text == item.text

      started = NaiveDateTime.utc_now()

      {:ok, timer} =
        Timer.start(%{item_id: item.id, person_id: 1, start: started})

      assert NaiveDateTime.diff(timer.start, started) == 0
    end

    test "Timer.stop/1 stops the timer that had been started" do
      {:ok, item} = Item.create_item(@valid_item_attrs)
      assert Item.get_item!(item.id).text == item.text

      {:ok, started} = 
        NaiveDateTime.new(Date.utc_today, Time.add(Time.utc_now, -1))

      {:ok, timer} =
        Timer.start(%{item_id: item.id, person_id: 1, start: started})

      assert NaiveDateTime.diff(timer.start, started) == 0

      ended = NaiveDateTime.utc_now()
      {:ok, timer} = Timer.stop(%{id: timer.id, stop: ended})
      assert NaiveDateTime.diff(timer.stop, timer.start) == 1
    end

    test "stop_timer_for_item_id(item_id) should stop the active timer (happy path)" do
      {:ok, item} = Item.create_item(@valid_item_attrs)
      {:ok, seven_seconds_ago} = 
        NaiveDateTime.new(Date.utc_today, Time.add(Time.utc_now, -7))
      # Start the timer 7 seconds ago:
      {:ok, timer} =
        Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})
      
      # stop the timer based on it's item_id
      Timer.stop_timer_for_item_id(item.id)
      
      stopped_timer = Timer.get_timer!(timer.id)
      assert NaiveDateTime.diff(stopped_timer.start, seven_seconds_ago) == 0
      assert NaiveDateTime.diff(stopped_timer.stop, stopped_timer.start) == 7
    end

    test "stop_timer_for_item_id(item_id) should not explode if there is no timer (unhappy path)" do
      zero_item_id = 0 # random int
      Timer.stop_timer_for_item_id(zero_item_id)
      assert "Don't stop believing!"
    end

    test "stop_timer_for_item_id(item_id) should not melt down if item_id is nil (sad path)" do
      nil_item_id = nil # random int
      Timer.stop_timer_for_item_id(nil_item_id)
      assert "Keep on truckin'"
    end
  end
end
```

## Make `timer` tests pass

Open the `lib/app/timer.ex` file
and replace the contents with the following code:

```elixir
defmodule App.Timer do
  use Ecto.Schema
  import Ecto.Changeset
  # import Ecto.Query
  alias App.Repo
  alias __MODULE__
  require Logger

  schema "timers" do
    field :item_id, :id
    field :start, :naive_datetime
    field :stop, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [:item_id, :start, :stop])
    |> validate_required([:item_id, :start])
  end

  @doc """
  `get_timer/1` gets a single Timer.

  Raises `Ecto.NoResultsError` if the Timer does not exist.

  ## Examples

      iex> get_timer!(123)
      %Timer{}
  """
  def get_timer!(id), do: Repo.get!(Timer, id)


  @doc """
  `start/1` starts a timer.

  ## Examples

      iex> start(%{item_id: 1, })
      {:ok, %Timer{start: ~N[2022-07-11 04:20:42]}}

  """
  def start(attrs \\ %{}) do
    %Timer{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  `stop/1` stops a timer.

  ## Examples

      iex> stop(%{id: 1})
      {:ok, %Timer{stop: ~N[2022-07-11 05:15:31], etc.}}

  """
  def stop(attrs \\ %{}) do
    get_timer!(attrs.id)
    |> changeset(%{stop: NaiveDateTime.utc_now})
    |> Repo.update()
  end

  @doc """
  `stop_timer_for_item_id/1` stops a timer for the given item_id if there is one.
  Fails silently if there is no timer for the given item_id.

  ## Examples

      iex> stop_timer_for_item_id(42)
      {:ok, %Timer{item_id: 42, stop: ~N[2022-07-11 05:15:31], etc.}}

  """
  def stop_timer_for_item_id(item_id) when is_nil(item_id) do
    Logger.debug("stop_timer_for_item_id/1 called without item_id: #{item_id} fail.")
  end

  def stop_timer_for_item_id(item_id) do
    # get timer by item_id find the latest one that has not been stopped:
    sql = """
    SELECT t.id FROM timers t 
    WHERE t.item_id = $1 
    AND t.stop IS NULL 
    ORDER BY t.id 
    DESC LIMIT 1;
    """
    res = Ecto.Adapters.SQL.query!(Repo, sql, [item_id])
    
    if res.num_rows > 0 do
      # IO.inspect(res.rows)
      timer_id = res.rows |> List.first() |> List.first()
      Logger.debug("Found timer.id: #{timer_id} for item: #{item_id}, attempting to stop.")
      stop(%{id: timer_id})
    else
      Logger.debug("No active timers found for item: #{item_id}")
    end
  end
end
```

The first few functions are simple again.
The more advanced function is `stop_timer_for_item_id/1`.
The _reason_ for the function is,
as it's name suggests,
to stop a `timer` for an `item` by its' `item_id`. 

We have written the function using "raw" `SQL` 
so that it's easier for people who are `new`
to `Phoenix`, and _specifically_ `Ecto` to understand.

# 5. `items` with `timers`

The _interesting_ thing we are UX-testing in the MVP
is the _combination_ of (todo list) `items` and `timers`.

So we need a way of: <br />
**a.** Selecting all the `timers` for a given `item` <br />
**b.** Accumulating the `timers` for the `item` <br />

> **Note**: We would have _loved_ 
to find a single `Ecto` function to do this,
but we didn't.
If you know of one,
please share!


## 5.1 Test for `accumulate_item_timers/1`

This might feel like we are working in reverse,
that's because we _are_!
We are working _back_ from our stated goal
of accumulating all the `timer` for a given `item`
so that we can display a _single_ elapsed time
when an `item` has had more than one timer.

Open the 
`test/app/item_test.exs`
file and add the following block of test code:

```elixir
  describe "accumulate timers for a list of items #103" do
    test "accumulate_item_timers/1 to display cumulative timer" do
      # https://hexdocs.pm/elixir/1.13/NaiveDateTime.html#new/2
      # "Add" -7 seconds: https://hexdocs.pm/elixir/1.13/Time.html#add/3
      {:ok, seven_seconds_ago} =
        NaiveDateTime.new(Date.utc_today, Time.add(Time.utc_now, -7))

      # this is the "shape" of the data that items_with_timers/1 will return:
      items_with_timers = [
        %{
          stop: nil,
          id: 3,
          start: nil,
          text: "This item has no timers",
          timer_id: nil
        },
        %{
          stop: ~N[2022-07-17 11:18:10.000000],
          id: 2,
          start: ~N[2022-07-17 11:18:00.000000],
          text: "Item #2 has one active (no end) and one complete timer should total 17sec",
          timer_id: 3
        },
        %{
          stop: nil,
          id: 2,
          start: seven_seconds_ago,
          text: "Item #2 has one active (no end) and one complete timer should total 17sec",
          timer_id: 4
        },
        %{
          stop: ~N[2022-07-17 11:18:31.000000],
          id: 1,
          start: ~N[2022-07-17 11:18:26.000000],
          text: "Item with 3 complete timers that should add up to 42 seconds elapsed",
          timer_id: 2
        },
        %{
          stop: ~N[2022-07-17 11:18:24.000000],
          id: 1,
          start: ~N[2022-07-17 11:18:18.000000],
          text: "Item with 3 complete timers that should add up to 42 seconds elapsed",
          timer_id: 1
        },
        %{
          stop: ~N[2022-07-17 11:19:42.000000],
          id: 1,
          start: ~N[2022-07-17 11:19:11.000000],
          text: "Item with 3 complete timers that should add up to 42 seconds elapsed",
          timer_id: 5
        }
      ]

      # The *interesting* timer is the *active* one (started seven_seconds_ago) ...
      # The "hard" part to test in accumulating timers are the *active* ones ...
      acc = Item.accumulate_item_timers(items_with_timers)
      item_map = Map.new(acc, fn item -> {item.id, item} end)
      item1 = Map.get(item_map, 1)
      item2 = Map.get(item_map, 2)
      item3 = Map.get(item_map, 3)

      # It's easy to calculate time elapsed for timers that have an stop:
      assert NaiveDateTime.diff(item1.stop, item1.start) == 42
      # This is the fun one that we need to be 17 seconds:
      assert NaiveDateTime.diff(NaiveDateTime.utc_now(), item2.start) == 17
      # The diff will always be 17 seconds because we control the start in the test data above.
      # But we still get the function to calculate it so we know it works.

      # The 3rd item doesn't have any timers, it's the control:
      assert item3.start == nil
    end
  end
```

This is a large test but most of it is the test data (`items_with_timers`) in the format we will be returning from 
`items_with_timers/1` in the next section. 

With that test in place, we can write the function.

## 5.2 Implement the `accummulate_item_timers/1` function

Open the 
`lib/app/item.ex`
file and add the following function:

```elixir
@doc """
  `accumulate_item_timers/1` aggregates the elapsed time
  for all the timers associated with an item
  and then subtracs that time from the start value of the *current* active timer.
  This is done to create the appearance that a single timer is being started/stopped
  when in fact there are multiple timers in the backend.
  For MVP we *could* have just had a single timer ...
  and given the "ugliness" of this code, I wish I had done that!!
  But the "USP" of our product [IMO] is that
  we can track the completion of a task across multiple work sessions.
  And having multiple timers is the *only* way to achieve that.

  If you can think of a better way of achieving the same result,
  please share: https://github.com/dwyl/app-mvp-phoenix/issues/103
  This function *relies* on the list of items being ordered by timer_id ASC
  because it "pops" the last timer and ignores it to avoid double-counting.
  """
  def accumulate_item_timers(items_with_timers) do
    # e.g: %{0 => 0, 1 => 6, 2 => 5, 3 => 24, 4 => 7}
    timer_id_diff_map = map_timer_diff(items_with_timers)

    # e.g: %{1 => [2, 1], 2 => [4, 3], 3 => []}
    item_id_timer_id_map = Map.new(items_with_timers, fn i ->
      { i.id, Enum.map(items_with_timers, fn it ->
          if i.id == it.id, do: it.timer_id, else: nil
        end)
        # stackoverflow.com/questions/46339815/remove-nil-from-list
        |> Enum.reject(&is_nil/1)
      }
    end)

    # this one is "wasteful" but I can't think of how to simplify it ...
    item_id_timer_diff_map = Map.new(items_with_timers, fn item ->
      timer_id_list = Map.get(item_id_timer_id_map, item.id, [0])
      # Remove last item from list before summing to avoid double-counting
      {_, timer_id_list} = List.pop_at(timer_id_list, -1)

      { item.id, Enum.reduce(timer_id_list, 0, fn timer_id, acc ->
          Map.get(timer_id_diff_map, timer_id) + acc
        end)
      }
    end)

    # creates a nested map: %{ item.id: %{id: 1, text: "my item", etc.}}
    Map.new(items_with_timers, fn item ->
      time_elapsed = Map.get(item_id_timer_diff_map, item.id)
      start = if is_nil(item.start), do: nil,
        else: NaiveDateTime.add(item.start, -time_elapsed)

      { item.id, %{item | start: start}}
    end)
    # Return the list of items without duplicates and only the last/active timer:
    |> Map.values()
    # Sort list by item.id descending (ordered by timer_id ASC above) so newest item first:
    |> Enum.sort_by(fn(i) -> i.id end, :desc)
  end
```

There's no getting around this,
the function is huge and not very pretty.
But hopefully the comments clarify it.

If anything is unclear, we're very happy to expand/explain.
We're also _very_ happy for anyone `else` to refactor it!
[Please open an issue](https://github.com/dwyl/app-mvp/issues/) 
so we can discuss. 🙏

## 5.3 Test for `items_with_timers/1`

Open the 
`test/app/item_test.exs`
file and the following test to the bottom:

```elixir
    test "Item.items_with_timers/1 returns a list of items with timers" do
      {:ok, item1} = Item.create_item(@valid_attrs)
      {:ok, item2} = Item.create_item(@valid_attrs)
      assert Item.get_item!(item1.id).text == item1.text

      started = NaiveDateTime.utc_now()

      {:ok, timer1} =
        Timer.start(%{item_id: item1.id, person_id: 1, start: started})
      {:ok, _timer2} =
        Timer.start(%{item_id: item2.id, person_id: 1, start: started})

      assert NaiveDateTime.diff(timer1.start, started) == 0

      # list items with timers:
      item_timers = Item.items_with_timers(1)
      assert length(item_timers) > 0
    end
```

## 5.4 Implement `items_with_timers/1`

Open the 
`lib/app/item.ex`
file and add the following code to the bottom:

```elixir
@doc """
  `items_with_timers/1` Returns a List of items with the latest associated timers.

  ## Examples

  iex> items_with_timers()
  [
    %{text: "hello", person_id: 1, status: 2, start: 2022-07-14 09:35:18},
    %{text: "world", person_id: 2, status: 7, start: 2022-07-15 04:20:42}
  ]
  """
  #
  def items_with_timers(person_id \\ 0) do
    sql = """
    SELECT i.id, i.text, i.status, i.person_id, t.start, t.stop, t.id as timer_id FROM items i
    FULL JOIN timers as t ON t.item_id = i.id
    WHERE i.person_id = $1 AND i.status IS NOT NULL AND i.status != 6
    ORDER BY timer_id ASC;
    """

    Ecto.Adapters.SQL.query!(Repo, sql, [person_id])
    |> map_columns_to_values()
    |> accumulate_item_timers()
  end


  @doc """
  `map_columns_to_values/1` takes an Ecto SQL query result
  which has the List of columns and rows separate
  and returns a List of Maps where the keys are the column names and values the data.

  Sadly, Ecto returns rows without column keys so we have to map them manually:
  ref: https://groups.google.com/g/elixir-ecto/c/0cubhSd3QS0/m/DLdQsFrcBAAJ
  """
  def map_columns_to_values(res) do
    Enum.map(res.rows, fn(row) ->
      Enum.zip(res.columns, row)
      |> Map.new |> AtomicMap.convert()
    end)
  end

  @doc """
  `map_timer_diff/1` transforms a list of items_with_timers
  into a flat map where the key is the timer_id and the value is the difference
  between timer.stop and timer.start
  If there is no active timer return {0, 0}.
  If there is no timer.stop return Now - timer.start

  ## Examples

  iex> list = [
    %{ stop: nil, id: 3, start: nil, timer_id: nil },
    %{ stop: ~N[2022-07-17 11:18:24], id: 1, start: ~N[2022-07-17 11:18:18], timer_id: 1 },
    %{ stop: ~N[2022-07-17 11:18:31], id: 1, start: ~N[2022-07-17 11:18:26], timer_id: 2 },
    %{ stop: ~N[2022-07-17 11:18:24], id: 2, start: ~N[2022-07-17 11:18:00], timer_id: 3 },
    %{ stop: nil, id: 2, start: seven_seconds_ago, timer_id: 4 }
  ]
  iex> map_timer_diff(list)
  %{0 => 0, 1 => 6, 2 => 5, 3 => 24, 4 => 7}
  """
  def map_timer_diff(list) do
    Map.new(list, fn item ->
      if is_nil(item.timer_id) do
        # item without any active timer
        { 0, 0}
      else
        { item.timer_id, timer_diff(item)}
      end
    end)
  end

  @doc """
  `timer_diff/1` calculates the difference between timer.stop and timer.start
  If there is no active timer OR timer has not ended return 0.
  The reasoning is: an *active* timer (no end) does not have to
  be subtracted from the timer.start in the UI ...
  Again, DRAGONS!
  """
  def timer_diff(timer) do
    # ignore timers that have not ended (current timer is factored in the UI!)
    if is_nil(timer.stop) do
      0
    else
      NaiveDateTime.diff(timer.stop, timer.start)
    end
  end
```

Once again, there is quite a lot going on here.
We have broken down the functions into chunks
and added inline comments to clarify the code.
But again, if anything is unclear please let us know!!


# 6. Add Authentication

This section borrows heavily from:
[dwyl/phoenix-liveview-chat-example](https://github.com/dwyl/phoenix-liveview-chat-example#12-authentication)

## 6.1 Add `auth_plug` to `deps`

Open the `mix.exs` file and add `auth_plug` to the `deps` section:

```elixir
{:auth_plug, "~> 1.4.14"},
```

Once the file is saved,
run:

```sh
mix deps.get
```

## 6.2 Get your `AUTH_API_KEY`

Follow the steps in the 
[docs](https://github.com/dwyl/auth_plug#2-get-your-auth_api_key-)
to get your `AUTH_API_KEY` environment variable. (1 minute)


## 6.2 Create Auth Controller

Create a new file with the path:
`lib/app_web/controllers/auth_controller.ex`
and add the following code:

```elixir
defmodule AppWeb.AuthController do
  use AppWeb, :controller
  import Phoenix.LiveView, only: [assign_new: 3]

  def on_mount(:default, _params, %{"jwt" => jwt} = _session, socket) do
    {:cont, AuthPlug.assign_jwt_to_socket(socket, &Phoenix.Component.assign_new/3, jwt)}
  end

  def on_mount(:default, _params, _session, socket) do
    socket = assign_new(socket, :loggedin, fn -> false end)
    {:cont, socket}
  end

  def login(conn, _params) do
    redirect(conn, external: AuthPlug.get_auth_url(conn, "/"))
  end

  def logout(conn, _params) do
    conn
    |> AuthPlug.logout()
    |> put_status(302)
    |> redirect(to: "/")
  end
end
```

# 7. Create `LiveView` Functions

_Finally_ we have all the "CRUD" functions we're going to need
we can focus on the `LiveView` code that will be the actual UI/UX!

## 7.1 Write `LiveView` Tests

Opent the 
`test/app_web/live/app_live_test.exs` 
file and replace the contents with the following test code:

```elixir
defmodule AppWeb.AppLiveTest do
  use AppWeb.ConnCase
  alias App.{Item, Timer}
  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "done"
    assert render(page_live) =~ "done"
  end

  test "connect and create an item", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_submit(view, :create,
      %{text: "Learn Elixir", person_id: 1}) =~ "Learn Elixir"
  end

  test "toggle an item", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: 0})
    {:ok, _item2} =
      Item.create_item(%{text: "Learn Elixir", status: 4, person_id: 0})

    assert item.status == 2

    started = NaiveDateTime.utc_now()
    {:ok, _timer} =
      Timer.start(%{item_id: item.id, start: started})

    # See: https://github.com/dwyl/useful/issues/17#issuecomment-1186070198
    # assert Useful.typeof(:timer_id) == "atom"
    assert Item.items_with_timers(1) > 0

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, :toggle,
      %{"id" => item.id, "value" => "on"}) =~ "line-through"

    updated_item = Item.get_item!(item.id)
    assert updated_item.status == 4
  end

  test "(soft) delete an item", %{conn: conn} do
    {:ok, item} = Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    assert item.status == 2

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :delete, %{"id" => item.id}) =~ "done"

    updated_item = Item.get_item!(item.id)
    assert updated_item.status == 6
  end

  test "start a timer", %{conn: conn} do
    {:ok, item} = Item.create_item(%{text: "Get Fancy!", person_id: 0, status: 2})

    assert item.status == 2

    {:ok, view, _html} = live(conn, "/")
    assert render_click(view, :start, %{"id" => item.id}) =~ "stop"
  end

  test "stop a timer", %{conn: conn} do
    {:ok, item} = Item.create_item(%{text: "Get Fancy!", person_id: 0, status: 2})

    assert item.status == 2
    started = NaiveDateTime.utc_now()
    {:ok, timer} = Timer.start(%{item_id: item.id, start: started})

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, :stop,
      %{"id" => item.id, "timerid" => timer.id}) =~ "done"
  end

  # This test is just to ensure coverage of the handle_info/2 function
  # It's not required but we like to have 100% coverage.
  # https://stackoverflow.com/a/60852290/1148249
  test "handle_info/2 start|stop", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} = Item.create_item(%{text: "Always Learning", person_id: 0, status: 2})
    started = NaiveDateTime.utc_now()
    {:ok, _timer} = Timer.start(%{item_id: item.id, start: started})

    send(view.pid, %{
      event: "start|stop",
      payload: %{items: Item.items_with_timers(1)}
    })

    assert render(view) =~ item.text
  end

  test "handle_info/2 update", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} = Item.create_item(%{text: "Always Learning", person_id: 0, status: 2})

    send(view.pid, %{
      event: "update",
      payload: %{items: Item.items_with_timers(1)}
    })

    assert render(view) =~ item.text
  end

  test "handle_info/2 delete", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} = Item.create_item(%{text: "Always Learning", person_id: 0, status: 6})

    send(view.pid, %{
      event: "delete",
      payload: %{items: Item.items_with_timers(1)}
    })

    refute render(view) =~ item.text
  end

  test "edit-item", %{conn: conn} do
    {:ok, item} = Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)}) =~
             "<form phx-submit=\"update-item\" id=\"form-update\""
  end

  test "update an item", %{conn: conn} do
    {:ok, item} = Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, view, _html} = live(conn, "/")

    assert render_submit(view, "update-item", %{"id" => item.id, "text" => "Learn more Elixir"}) =~
             "Learn more Elixir"

    updated_item = Item.get_item!(item.id)
    assert updated_item.text == "Learn more Elixir"
  end

  test "timer_text(start, stop)" do
    timer = %{
      start: ~N[2022-07-17 09:01:42.000000],
      stop: ~N[2022-07-17 13:22:24.000000]
    }

    assert AppWeb.AppLive.timer_text(timer) == "04:20:42"
  end

  test "get / with valid JWT", %{conn: conn} do
    data = %{email: "test@dwyl.com", givenName: "Alex", picture: "this", auth_provider: "GitHub", id: 2}
    jwt = AuthPlug.Token.generate_jwt!(data)

    {:ok, view, _html} = live(conn, "/?jwt=#{jwt}")
    assert render(view)
  end

  test "Logout link displayed when loggedin", %{conn: conn} do
    data = %{email: "test@dwyl.com", givenName: "Alex", picture: "this", auth_provider: "GitHub", id: 2}
    jwt = AuthPlug.Token.generate_jwt!(data)

    conn = get(conn, "/?jwt=#{jwt}")
    assert html_response(conn, 200) =~ "logout"
  end

  test "get /logout with valid JWT", %{conn: conn} do
    data = %{
      email: "test@dwyl.com",
      givenName: "Alex",
      picture: "this",
      auth_provider: "GitHub",
      sid: 1,
      id: 2
    }

    jwt = AuthPlug.Token.generate_jwt!(data)

    conn =
      conn
      |> put_req_header("authorization", jwt)
      |> get("/logout")

    assert "/" = redirected_to(conn, 302)
  end

  test "test login link redirect to auth.dwyl.com", %{conn: conn} do
    conn = get(conn, "/login")
    assert redirected_to(conn, 302) =~ "auth.dwyl.com"
  end
end
```

These tests are written in the order we created them.
Feel free to comment out all but one at a time
to implement the functions gradually.


## 7.2 Implement the `LiveView` functions

Open the 
`lib/app_web/live/app_live.ex`
file and replace the contents with the following code:

```elixir
defmodule AppWeb.AppLive do
  use AppWeb, :live_view
  alias App.{Item, Timer}
  # run authentication on mount
  on_mount AppWeb.AuthController
  alias Phoenix.Socket.Broadcast

  @topic "live"

  defp get_person_id(assigns) do
    if Map.has_key?(assigns, :person) do
      assigns.person.id
    else
      0
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@topic)

    person_id = get_person_id(socket.assigns)
    items = Item.items_with_timers(person_id)
    {:ok, assign(socket, items: items, editing: nil, filter: "active")}
  end

  @impl true
  def handle_event("create", %{"text" => text}, socket) do
    person_id = get_person_id(socket.assigns)
    Item.create_item(%{text: text, person_id: person_id, status: 2})

    AppWeb.Endpoint.broadcast(@topic, "update", :create)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", data, socket) do
    # Toggle the status of the item between 3 (:active) and 4 (:done)
    status = if Map.has_key?(data, "value"), do: 4, else: 3

    # need to restrict getting items to the people who own or have rights to access them!
    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{status: status})
    Timer.stop_timer_for_item_id(item.id)

    AppWeb.Endpoint.broadcast(@topic, "update", :toggle)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => item_id}, socket) do
    Item.delete_item(item_id)
    AppWeb.Endpoint.broadcast(@topic, "update", :delete)
    {:noreply, socket}
  end

  @impl true
  def handle_event("start", data, socket) do
    item = Item.get_item!(Map.get(data, "id"))
    person_id = get_person_id(socket.assigns)

    {:ok, _timer} =
      Timer.start(%{
        item_id: item.id,
        person_id: person_id,
        start: NaiveDateTime.utc_now()
      })

    AppWeb.Endpoint.broadcast(@topic, "update", :start)
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", data, socket) do
    timer_id = Map.get(data, "timerid")
    {:ok, _timer} = Timer.stop(%{id: timer_id})

    AppWeb.Endpoint.broadcast(@topic, "update", :stop)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit-item", data, socket) do
    {:noreply, assign(socket, editing: String.to_integer(data["id"]))}
  end

  @impl true
  def handle_event("update-item", %{"id" => item_id, "text" => text}, socket) do
    current_item = Item.get_item!(item_id)
    Item.update_item(current_item, %{text: text})

    AppWeb.Endpoint.broadcast(@topic, "update", :update)
    {:noreply, assign(socket, editing: nil)}
  end

  @impl true
  def handle_info(%Broadcast{event: "update", payload: _message}, socket) do
    person_id = get_person_id(socket.assigns)
    items = Item.items_with_timers(person_id)

    {:noreply, assign(socket, items: items)}
  end

  # only show certain UI elements (buttons) if there are items:
  def has_items?(items), do: length(items) > 1

  # 2: uncategorised (when item are created), 3: active
  def active?(item), do: item.status == 2 || item.status == 3
  def done?(item), do: item.status == 4
  def archived?(item), do: item.status == 6

  # Check if an item has an active timer
  def started?(item) do
    not is_nil(item.start) and is_nil(item.stop)
  end

  # An item without an end should be counting
  def timer_stopped?(item) do
    not is_nil(item.stop)
  end

  def timers_any?(item) do
    not is_nil(item.timer_id)
  end

  # Convert Elixir NaiveDateTime to JS (Unix) Timestamp
  def timestamp(naive_datetime) do
    DateTime.from_naive!(naive_datetime, "Etc/UTC")
    |> DateTime.to_unix(:millisecond)
  end

  # Elixir implementation of `timer_text/2`
  def leftPad(val) do
    if val < 10, do: "0#{to_string(val)}", else: val
  end

  def timer_text(item) do
    if is_nil(item) or is_nil(item.start) or is_nil(item.stop) do
      ""
    else
      diff = timestamp(item.stop) - timestamp(item.start)

      # seconds
      s =
        if diff > 1000 do
          s = (diff / 1000) |> trunc()
          s = if s > 60, do: Integer.mod(s, 60), else: s
          leftPad(s)
        else
          "00"
        end

      # minutes
      m =
        if diff > 60000 do
          m = (diff / 60000) |> trunc()
          m = if m > 60, do: Integer.mod(m, 60), else: m
          leftPad(m)
        else
          "00"
        end

      # hours
      h =
        if diff > 3_600_000 do
          h = (diff / 3_600_000) |> trunc()
          leftPad(h)
        else
          "00"
        end

      "#{h}:#{m}:#{s}"
    end
  end

  # Filter element by status (active, archived & done; default: all)
  # see https://hexdocs.pm/phoenix_live_view/live-navigation.html
  @impl true
  def handle_params(params, _uri, socket) do
    # person_id = get_person_id(socket.assigns)
    # items = Item.items_with_timers(person_id)
    filter = params["filter_by"] || socket.assigns.filter

    {:noreply, assign(socket, filter: filter)}
  end

  defp filter_items(items, filter) do
    case filter do
      "active" ->
        Enum.filter(items, &active?(&1))

      "done" ->
        Enum.filter(items, &done?(&1))

      "archived" ->
        Enum.filter(items, &archived?(&1))

      _ ->
        items
    end
  end

  def class_footer_link(filter_name, filter_selected) do
    if filter_name == filter_selected do
      "px-2 py-2 h-9 mr-1 bg-teal-500 text-white rounded-md"
    else
      """
      py-2 px-4 bg-transparent font-semibold
      border rounded border-teal-500 text-teal-500
      hover:text-white hover:bg-teal-500 hover:border-transparent
      """
    end
  end
end
```

Again, a bunch of code here.
Please work through each function 
to understand what is going on.


# 8. Implement the `LiveView` UI Template

_Finally_ we have all the `LiveView` functions,

## 8.1 Update the `root` layout/template

Open the
`lib/app_web/templates/layout/root.html.heex`
file and replace the contents with the following:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="csrf-token" content={csrf_token_value()}>
    <meta
      http-equiv="Content-Security-Policy"
      content="
        default-src 'self' dwyl.com https://*.cloudflare.com plausible.io; 
        connect-src 'self' wss://mvp.fly.dev plausible.io;
        form-action 'self';
        img-src *; child-src 'none';
        script-src 'self' https://cdnjs.cloudflare.com plausible.io 'unsafe-eval' 'unsafe-inline';
        style-src 'self' 'unsafe-inline';
      "
    />
    <%= live_title_tag assigns[:page_title] || "dwyl mvp"%>
    <%= render "icons.html" %>
    <link phx-track-static rel="stylesheet" href={Routes.static_path(@conn, "/assets/app.css")}/> 
    <script defer phx-track-static type="text/javascript" 
      src={Routes.static_path(@conn, "/assets/app.js")}></script>
    <!-- see: https://github.com/dwyl/learn-alpine.js -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/alpinejs/3.10.2/cdn.js" defer></script>
  </head>
  <body>   
    <nav x-data="{ openMenu: false }" class="bg-gray-800">
      <div class="mx-auto max-w-7xl px-2 sm:px-6 lg:px-8">
        <div class="relative flex h-16 items-center justify-between">
          <div class="absolute inset-y-0 left-0 flex items-center pr-2">
            <%= if @loggedin do %>
              <!-- Profile dropdown -->
              <div
                x-data="{showProfileDropdown: false}"
                x-on:click="showProfileDropdown = !showProfileDropdown"
                class="relative ml-3"
              >
                <div>
                  <button
                    type="button"
                    class="flex rounded-full bg-gray-800 text-sm focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800"
                    id="user-menu-button"
                    aria-expanded="false"
                    aria-haspopup="true"
                  >
                    <span class="sr-only">Open user menu</span>
                    <img
                      src={@person.picture}
                      class="h-8 w-8 rounded-full"
                      alt="avatar image"
                    />
                  </button>
                </div>
                <!-- Dropdown menu, show/hide based on menu state. -->
                <div
                  x-show="showProfileDropdown"
                  x-on:click.away="showProfileDropdown = false"
                  x-transition:enter="transition ease-out duration-100"
                  x-transition:enter-start="transform opacity-0 scale-95"
                  x-transition:enter-end="transform opacity-100 scale-100"
                  x-transition:leave="transition ease-in duration-75"
                  x-transition:leave-start="transform opacity-100 scale-100"
                  x-transition:leave-end="transform opacity-0 scale-95"
                  class="absolute left-0 z-10 mt-2 w-48 origin-top-left rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
                  role="menu"
                  aria-orientation="vertical"
                  aria-labelledby="user-menu-button"
                  tabindex="-1"
                >
                  <!-- Active: "bg-gray-100", Not Active: "" -->
                  <%= link to: "/logout" , class: "block px-4 py-2 text-sm text-gray-700" do %>
                    Sign out
                  <% end %>
                </div>
              </div>
            <% else %>
              <div class="flex-shrink-0">
                <%= link to: "/login" , class: "relative inline-flex items-center gap-x-1.5 rounded-md bg-[#0F766E] px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-opacity-90 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500" do %>
                  Login
                <% end %>
              </div>
            <% end %>
          </div>

          <div class="flex flex-1 items-center justify-center">
            <div class="flex flex-shrink-0 items-center">
              <a href="/" class="flex items-center">
                <img
                  src="https://dwyl.com/img/common/dwyl-heart-only-logo.png"
                  height="32"
                  width="32"
                  alt="dwyl logo"
                />
              </a>
            </div>
          </div>

          <div class="absolute inset-y-0 right-0 flex items-center">
            <!-- Mobile menu button-->
            <button
              x-on:click="openMenu = !openMenu"
              type="button"
              class="inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-700 hover:text-white focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
              aria-controls="mobile-menu"
              aria-expanded="false"
            >
              <span class="sr-only">Open main menu</span>
              <!--
                Icon when menu is closed.

                Menu open: "hidden", Menu closed: "block"
              -->
              <svg
                class="block h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                />
              </svg>
              <!--
                Icon when menu is open.

                Menu open: "block", Menu closed: "hidden"
              -->
              <svg
                class="hidden h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
      <!-- Mobile menu, show/hide based on menu state. -->
      <div x-show="openMenu" id="mobile-menu">
        <div class="space-y-1 px-2 pb-3 pt-2 text-right">
          <!--  <a href="#" class="bg-gray-900 text-white rounded-md px-3 py-2 text-sm font-medium" aria-current="page">Current</a> -->
          <%= link("Tags",
            to: "/tags",
            class:
              "text-gray-300 hover:bg-gray-700 hover:text-white rounded-md px-3 py-2 text-sm font-medium"
          ) %>
        </div>
      </div>
    </nav>
    <%= @inner_content %>
  </body>
</html>
```

Note that we are defining a content security policy with:

```html
<meta
  http-equiv="Content-Security-Policy"
  content="
    default-src 'self' dwyl.com https://*.cloudflare.com plausible.io; 
    connect-src 'self' wss://mvp.fly.dev plausible.io;
    form-action 'self';
    img-src *; child-src 'none';
    script-src 'self' https://cdnjs.cloudflare.com plausible.io 'unsafe-eval' 'unsafe-inline';
    style-src 'self' 'unsafe-inline';
  "
/>
```

This defines who can run scripts, forms, style css and images on the browser.

The `default-src` value is used by default when the [fetch directives](https://developer.mozilla.org/en-US/docs/Glossary/Fetch_directive)
are not specified.

For scripts we want to allow `cloudfare` (used for cdn) and [`plausible`](https://plausible.io/) used 
as an alternative to Google Analytics, to run javascript scripts.

The `self` value allows the server itself (the Phoenix application) to run scripts.

Read more about content security policy at https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP

## 8.2 Create the `icons` template

To make the App more Mobile-friendly,
we define a bunch of iOS/Android related icons.

Create a new file with the path 
`lib/app_web/templates/layout/icons.html.heex`
and add the following code to it:

```html
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="dwyl is a worldwide community of people using technology to solve real problems.">
<meta name="robots" content="noarchive">
<link rel="shortcut-icon" href="https://dwyl.com/img/favicon.ico">
<link rel="apple-touch-icon" sizes="57x57" href="https://dwyl.com/img/apple-icon-57x57.png">
<link rel="apple-touch-icon" sizes="60x60" href="https://dwyl.com/img/apple-icon-60x60.png">
<link rel="apple-touch-icon" sizes="72x72" href="https://dwyl.com/img/apple-icon-72x72.png">
<link rel="apple-touch-icon" sizes="76x76" href="https://dwyl.com/img/apple-icon-76x76.png">
<link rel="apple-touch-icon" sizes="114x114" href="https://dwyl.com/img/apple-icon-114x114.png">
<link rel="apple-touch-icon" sizes="120x120" href="https://dwyl.com/img/apple-icon-120x120.png">
<link rel="apple-touch-icon" sizes="144x144" href="https://dwyl.com/img/apple-icon-144x144.png">
<link rel="apple-touch-icon" sizes="152x152" href="https://dwyl.com/img/apple-icon-152x152.png">
<link rel="apple-touch-icon" sizes="180x180" href="https://dwyl.com/img/apple-icon-180x180.png">
<link rel="icon" type="image/png" sizes="192x192" href="https://dwyl.com/img/android-icon-192x192.png">
<link rel="icon" type="image/png" sizes="32x32" href="https://dwyl.com/img/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="96x96" href="https://dwyl.com/img/favicon-96x96.png">
<link rel="icon" type="image/png" sizes="16x16" href="https://dwyl.com/img/favicon-16x16.png">
<link rel="manifest" href="https://dwyl.com/img/manifest.json">
<meta name="msapplication-TileColor" content="#ffffff">
<meta name="msapplication-TileImage" content="https://dwyl.com/img/ms-icon-144x144.png">
```

This is static and very repetitive, 
hence creating a partial to hide it from the root layout.

Finally ...


# 9. Update the `LiveView` Template

Open the `app_live.html.heex` 
file and replace the contents 
with the following template code:

```html
<div class="h-90 w-full font-sans">
  <form phx-submit="create" class="w-full lg:w-3/4 lg:max-w-lg text-center mx-auto">

    <!-- textarea so that we can have multi-line capturing 
      help wanted auto re-sizing: https://github.com/dwyl/learn-alpine.js/issues/3 -->
    <textarea 
      class="w-full py-1 px-1 text-slate-800 text-3xl
        bg-white bg-clip-padding
        resize-none
        max-h-80
        transition ease-in-out
        border border-b border-slate-200
        focus:border-none focus:outline-none"
      name="text" 
      placeholder="What needs to be done?" 
      autofocus="" 
      required="required" 
      x-data="{resize() {
           $el.style.height = '80px';
           $el.style.height = $el.scrollHeight + 'px';
        }
      }"
      x-init="resize"
      x-on:input="resize"
    ></textarea>

    <!-- Want to help "DRY" this? see: https://github.com/dwyl/app-mvp-phoenix/issues/105 -->
    <!-- https://tailwindcss.com/docs/justify-content#end -->
    <div class="flex justify-end mr-1">
      <button class="inline-flex items-center px-2 py-1 mt-1 h-9
        bg-green-500 hover:bg-green-600 text-white rounded-md">
        <svg xmlns="http://www.w3.org/2000/svg" 
          class="h-5 w-5 mr-2" fill="none" 
          viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
            d="M15 13l-3 3m0 0l-3-3m3 3V8m0 13a9 9 0 110-18 9 9 0 010 18z"
          />
        </svg>
        Save
      </button>
    </div>

  </form>

  <!-- List of items with inline buttons and controls -->
  <ul class="w-full">
    <%= for item <- @items do %>
    <li data-id={item.id} class="mt-2 flex w-full border-t border-slate-200 py-2">

      <!-- if item is "done" (status: 4) strike-through and show "Archive" button -->
      <%= if done?(item) do %>
        <input type="checkbox" phx-value-id={item.id} phx-click="toggle"
          class="flex-none p-4 m-2 form-checkbox text-slate-400" 
          checked />
        <label class="w-full text-slate-400  m-2 line-through">
          <%= item.text %>
        </label>

        <div class="flex flex-col">
        <div class="flex flex-col justify-end mr-1">
          <!-- "Archive" button with icon see: https://github.com/dwyl/app-mvp-phoenix/issues/101 -->
          <button class="inline-flex items-center px-2 py-1 mr-2 h-9
          bg-gray-200 hover:bg-gray-300 text-gray-800 rounded-md"
            phx-click="delete" phx-value-id={item.id}>
            <svg xmlns="http://www.w3.org/2000/svg" 
              class="h-5 w-5 mr-2" fill="none" 
              viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
            </svg>
            Archive
          </button>
          <p> 
            <span class="text-sm font-mono font-semibold flex flex-col justify-end text-right mr-2 mt-1"> 
              <%= timer_text(item) %> 
            </span>
          </p>
        </div>
      </div>

      <!-- else render the buttons for start|stop timer -->
      <% else %>
        <!-- Show checkbox so the item can be marked as "done" -->
        <input type="checkbox" phx-value-id={item.id} phx-click="toggle"
          class="flex-none p-4 m-2 form-checkbox hover:text-slate-600" />

        <!-- Editing renders the textarea and "save" button - near identical (duplicate) code from above
          Help wanted DRY-ing this ... see: https://github.com/dwyl/app-mvp-phoenix/issues/105 -->
        <%= if item.id == @editing do %>
          <form phx-submit="update-item" id="form-update" class="w-full mr-2">
            <textarea 
              id="editing"
              class="w-full flex-auto text-slate-800
                bg-white bg-clip-padding
                transition ease-in-out
                border border-b border-slate-200
                focus:border-none focus:outline-none"
              name="text" 
              placeholder="What is on your mind?" 
              autofocus 
              required="required" 
              value={item.text}
            ><%= item.text %></textarea>

            <input type="hidden" name="id" value={item.id}/>

            <div class="flex justify-end mr-1">
              <button class="inline-flex items-center px-2 py-1 mt-1 h-9
                bg-green-500 hover:bg-green-600 text-white rounded-md">
                <svg xmlns="http://www.w3.org/2000/svg" 
                  class="h-5 w-5 mr-2" fill="none" 
                  viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M15 13l-3 3m0 0l-3-3m3 3V8m0 13a9 9 0 110-18 9 9 0 010 18z"
                  />
                </svg>
                Save
              </button>
            </div>

          </form>
        <% else  %>
          <!-- Render item.text as click-able label -->
          <label class="w-full flex-auto text-slate-800 m-2"
            phx-click="edit-item" phx-value-id={item.id}>
            <%= item.text %>
          </label>
        <% end %>

       <%= if timers_any?(item) do %>
          <!-- always display the time elapsed in the UI https://github.com/dwyl/app-mvp-phoenix/issues/106 -->
          <%= if timer_stopped?(item) do %>
            <div class="flex flex-col">
              <div class="flex flex-col justify-end mr-1">
                <!-- render "continue" button -->
                <button phx-click="start" phx-value-id={item.id}
                  class="inline-flex items-center px-2 py-2 h-9 mr-1
                  bg-teal-600 hover:bg-teal-800 text-white rounded-md">
                  <svg xmlns="http://www.w3.org/2000/svg" 
                    class="h-5 w-5 mr-1" fill="none" 
                    viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                  Resume
                </button>
                <p> 
                  <span class="text-sm font-mono font-semibold flex flex-col justify-end text-right mr-2 mt-1"> 
                    <%= timer_text(item) %> 
                  </span>
                </p>
              </div>
            </div>
          <% else %>
            <%= if started?(item) do %>
              <!-- render the counting timer with Apline.js! see: github.com/dwyl/learn-alpine.js -->
              <div class="flex flex-col"
                x-data="{
                  start: parseInt($refs.timer_start.innerHTML, 10),
                  current: null, 
                  stop: null, 
                  interval: null
                }"
                x-init="
                  start = parseInt($refs.timer_start.innerHTML, 10);
                  current = start;
                  interval = setInterval(() => { current = Date.now() }, 500)
                "
                >
                <!-- this is how we pass the start|stop time from Elixir (server) to Alping (client) -->
                <span x-ref="timer_start" class="hidden"><%= timestamp(item.start) %></span>

                <div class="flex flex-col justify-end mr-1">
                  <button phx-click="stop" phx-value-id={item.id} phx-value-timerid={item.timer_id}
                    class="inline-flex items-center px-2 py-2 h-9 mr-1
                    bg-red-500 hover:bg-red-700 text-white rounded-md">
                    <svg xmlns="http://www.w3.org/2000/svg" 
                      class="h-5 w-5 mr-1" fill="none" 
                      viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                      />
                    </svg>
                    Stop
                  </button>

                  <p><span x-text="timer_text(start, current || stop)"
                    class="text-sm font-mono font-semibold text-right mr-1">00:00:00</span></p>
                </div>
              </div>           
            <% end %> <!-- end if started?(item) -->
          <% end %>
        <% else %>
          <!-- render start button -->
          <button phx-click="start" phx-value-id={item.id}
            class="inline-flex items-center px-2 py-2 h-9 mr-1
            bg-teal-500 hover:bg-teal-700 text-white rounded-md">
            <svg xmlns="http://www.w3.org/2000/svg" 
              class="h-5 w-5 mr-1" fill="none" 
              viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            Start
          </button>
        <% end %><!-- end timers_any?(item) -->
      <% end %>
            
    </li>
    <% end %><!-- end for item <- @items -->
  </ul>
</div>

<script>
// Render the *counting* timer using JavaScript
// (Stopped timers are rendered by Elixir)

function leftPad(val) {
  return val < 10 ? '0' + String(val) : val;
}

function timer_text(start, current) {
  console.log("timer_text(start, current)", start, current)
  let h="00", m="00", s="00";
  const diff = current - start;
  // seconds
  if(diff > 1000) {
    s = Math.floor(diff / 1000);
    s = s > 60 ? s % 60 : s;
    s = leftPad(s);
  }
  // minutes
  if(diff > 60000) {
    m = Math.floor(diff/60000);
    m = m > 60 ? m % 60 : m;
    m = leftPad(m)
  }
  // hours
  if(diff > 3600000) {
    h = Math.floor(diff/3600000);
    h = leftPad(h)
  }

  return h + ':' + m + ':' + s;
}
</script>
```

The bulk of the App is contained in this one template file. <br />
Work your way through it and if anything is unclear,
let us know!

# 10. Filter Items

On this section we want to add LiveView links to filter items by status.
We first update the template to add the following footer
in the `lib/app_web/live/app_live.html.heex` file:


```html
<%= if has_items?(@items) do %>
<footer>
  <div class="flex flex-row justify-center p-2 border-t">
    <div class="px-8 py-2"><%= live_patch "All", to: Routes.live_path(@socket, AppWeb.AppLive, %{filter_by: "all"}), class: class_footer_link("all", @filter)  %></div> 
    <div class="px-8 py-2"><%= live_patch "Active", to: Routes.live_path(@socket, AppWeb.AppLive, %{filter_by: "active"}), class: class_footer_link("active",@filter)  %></div> 
    <div class="px-8 py-2"><%= live_patch "Done", to: Routes.live_path(@socket, AppWeb.AppLive, %{filter_by: "done"} ), class: class_footer_link("done", @filter) %></div> 
    <div class="px-8 py-2"><%= live_patch "Archived", to: Routes.live_path(@socket, AppWeb.AppLive, %{filter_by: "archived"} ), class: class_footer_link("archived", @filter) %></div> 
  </div>
</footer>
<% end %>
<script>
...
```


We are creating four `live_patch` links: "All", "Active", "Done" and "Archived".
When a linked is clicked `LiveView` will search for the `handle_params` function
in our `AppWeb.AppLive` module. If we check the 
`app_live.ex` file, we will notice these functions
(**don't copy this code, it's already inside the file**):

```elixir
  # only show certain UI elements (buttons) if there are items:
  def has_items?(items), do: length(items) > 1


  @impl true
  def handle_params(params, _uri, socket) do
    person_id = get_person_id(socket.assigns)
    filter = params["filter_by"] || socket.assigns.filter

    items =
      Item.items_with_timers(person_id)
      |> filter_items(filter)

    {:noreply, assign(socket, items: items, filter: filter)}
  end

  defp filter_items(items, filter) do
    case filter do
      "active" ->
        Enum.filter(items, &active?(&1))

      "done" ->
        Enum.filter(items, &done?(&1))

      "archived" ->
        Enum.filter(items, &archived?(&1))

      _ ->
        items
    end
  end
```

For each of the possible filters the function assigns to the socket the filtered
list of items. Similar to our `done?` function we have created the `active?` and
`archived?` functions which check the status value of an item
(**don't copy this code, it's already inside the file**):

```elixir
  def active?(item), do: item.status == 2 || item.status == 3
  def done?(item), do: item.status == 4
  def archived?(item), do: item.status == 6
```

Now that we have the new filtered list of items assigned to the socket, we need
to make sure `archived` items are displayed. Let's update our template
`app_live.html.heex` with:

```html
  <!-- List of items with inline buttons and controls -->
  <ul class="w-full">
    <%= for item <- @items do %>
    <li data-id={item.id} class="mt-2 flex w-full border-t border-slate-200 py-2">

      <%= if archived?(item) do %>
        <input type="checkbox" phx-value-id={item.id} phx-click="toggle"
          class="flex-none p-4 m-2 form-checkbox text-slate-400 cursor-not-allowed" 
          checked disabled />
        <label class="w-full text-slate-400  m-2 line-through">
          <%= item.text %>
        </label>

        <div class="flex flex-col">
          <div class="flex flex-col justify-end mr-1">
            <button disabled class="cursor-not-allowed inline-flex items-center px-2 py-1 mr-2 h-9
            bg-gray-200 text-gray-800 rounded-md">
              <svg xmlns="http://www.w3.org/2000/svg" 
                class="h-5 w-5 mr-2" fill="none" 
                viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                  d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
              </svg>
              Archived
            </button>
          </div>
        </div>


      <% else %>
      <!-- if item is "done" (status: 4) strike-through and show "Archive" button -->
      <%= if done?(item) do %>


      ...


        <% end %>   <!-- don't forget to add this one!!! -->
      </li>
      <% end %><!-- end for item <- @items -->
```

For each items we first check if the status is `archived`.
If it is we then displayed the checkbox checked and disabled and we also displayed
an `arhived` disabled button to make it obvious the item is archived.


Finally we can add the following test to make sure our filtering feature is working
as we expect:

```elixir
  test "filter items", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Item to do", person_id: 0, status: 2})

    {:ok, item_done} =
      Item.create_item(%{text: "Item done", person_id: 0, status: 4})

    {:ok, item_archived} =
      Item.create_item(%{text: "Item archived", person_id: 0, status: 6})

    {:ok, view, _html} = live(conn, "/?filter_by=all")
    assert render(view) =~ "Item to do"
    assert render(view) =~ "Item done"
    assert render(view) =~ "Item archived"

    {:ok, view, _html} = live(conn, "/?filter_by=active")
    assert render(view) =~ "Item to do"
    refute render(view) =~ "Item done"
    refute render(view) =~ "Item archived"

    {:ok, view, _html} = live(conn, "/?filter_by=done")
    refute render(view) =~ "Item to do"
    assert render(view) =~ "Item done"
    refute render(view) =~ "Item archived"

    {:ok, view, _html} = live(conn, "/?filter_by=archived")
    refute render(view) =~ "Item to do"
    refute render(view) =~ "Item done"
    assert render(view) =~ "Item archived"
  end
```

We are creating 3 items and testing depending on the filter selected that the 
items are properly displayed and removed from the view.

See also the [Live Navigation](https://hexdocs.pm/phoenix_live_view/live-navigation.html)
Phoenix documentation for using `live_patch`

# 11. Tags

In this section we're going to add tags to items.
`Tags` belong to a `person` 
(i.e. different `people` can create the _same_ `tag` name).
A `person` can't create `tag` duplicates (case insensitive).


## 11.1 Migrations

We first want to create a new `tags` table in our database.
We can use the `mix ecto.gen.migration add_tags` command to create a new
migration and then create manually a `App.Tag` schema, or we can directly use
the [mix phx.gen.schema](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html)
command to create the schema and the migration in one step:

```sh
mix phx.gen.schema Tag tags person_id:integer text:string
```

You should see a similar response:

```sh
* creating lib/app/tags.ex
* creating priv/repo/migrations/20220922084231_create_tags.exs

Remember to update your repository by running migrations:

    $ mix ecto.migrate
```


We can repeat this process to create a `items_tags` table and `ItemTag`
schema. This [join table](https://en.wikipedia.org/wiki/Associative_entity)
is used to link items and tags together.

```sh
mix phx.gen.schema ItemTag items_tags item_id:references:items tag_id:references:tags
```

We are using the [references](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html#module-attributes)
attribute to link the `item_id` field to the `items` table and `tag_id` to `tags`.

Here's how the ER diagram should look so far.

<img width="335" alt="full_diagram" src="https://user-images.githubusercontent.com/17494745/198112185-345e3720-5b62-49c3-ab5f-607b5b7f23c2.png">


Before running our migrations file, we need to add a few changes to them.


In our `create_tags` migration, update the file
`priv/repo/migrations/XXXXXXXXX_create_tags.exs`
 to:

```elixir
  def change do
    create table(:tags) do
      add(:person_id, :integer)
      add(:text, :string)

      timestamps()
    end

    create(unique_index(:tags, ["lower(text)", :person_id], name: tags_text_person_id_index))
  end
```

We have added a unique index on the fields `text` and `person_id`.
We have specified the name `tags_text_person_id_index` to the index to make
sure later on to use it in the `Tag` changeset.
This means a person can't create duplicated tags.
The `"lower(text)"` function also makes sure the tags are case insensitive,
for example if a tag `UI` has been created, the person then won't be able to create
the `ui` tag.


Another solution for case insensitive with Postgres is to use the
`citext` extension. Update the migration with:

```elixir

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext"

    create table(:tags) do
      add(:person_id, :integer)
      add(:text, :citext)

      timestamps()
    end

    create(unique_index(:tags, [:text, :person_id], name: tags_text_person_id_index))
  end
```

And that's all, Postgres will take care of checking the text value case-sensitivity
for us.



see also for some information about `lower` and `citext`:
- https://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3-case-sensitivity
- https://elixirforum.com/t/case-insensitive-column-in-ecto/2062/5
- https://www.postgresql.org/docs/current/citext.html
- https://nandovieira.com/using-insensitive-case-columns-in-postgresql-with-citext



In our `create_items_tags` migration, update the file with:

```elixir
  def change do
    create table(:items_tags, primary_key: false) do
      add(:item_id, references(:items, on_delete: :delete_all))
      add(:tag_id, references(:tags, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:items_tags, [:item_id, :tag_id]))
  end
```

- We have added the `primary_key: false` option. This to avoid having the `id`
column created automatically by the migration.

- We've updated the `on_delete` option to `delete_all`. This means that if an
item or a tag is deleted, we then remove the rows linked to this item/tag 
in the join table `items_tags`. However if for example an item is deleted the
references in the join table will be removed but the tags linked to the deleted
item won't be removed.

The [`on_delete` values](https://hexdocs.pm/ecto_sql/Ecto.Migration.html#references/2-options)
can be 
- `:nothing` (default), Postgres raises an error if the deleted data is still linked in
the join table
- `:delete_all`, delete the data and the references in the join table
- `:nilify_all`, delete the data and change the id to nil in the join table
- `:restrict`, similar to `:nothing`, see https://stackoverflow.com/questions/60043008/when-to-use-nothing-or-restrict-for-on-delete-with-ecto


- Finally we create a unique index on the `item_id` and `tag_id` fields to make
sure that the same tag can't be added multiple times to an item.


We can now run our migrations with `mix ecto.migrate`:

```sh
Compiling 2 files (.ex)
Generated app app

10:16:42.276 [info]  == Running 20220922091606 App.Repo.Migrations.CreateTags.change/0 forward

10:16:42.279 [info]  create table tags

10:16:42.284 [info]  == Migrated 20220922091606 in 0.0s

10:16:42.307 [info]  == Running 20220922091636 App.Repo.Migrations.CreateItemsTags.change/0 forward

10:16:42.307 [info]  create table items_tags

10:16:42.313 [info]  create index items_tags_item_id_index

10:16:42.315 [info]  create index items_tags_tag_id_index

10:16:42.316 [info]  == Migrated 20220922091636 in 0.0s
```

## 11.2 Schemas

Now that our database is setup for tags, we can update our schemas.


In `lib/app/tag.ex`, update the file to:


```elixir
defmodule App.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.{Item, ItemTag}

  schema "tags" do
    field :text, :string
    field :person_id, :integer

    many_to_many(:items, Item, join_through: ItemTag)
    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:person_id, :text])
    |> validate_required([:person_id, :text])
    |> unique_constraint([:person_id, :text], name: :tags_text_person_id_index)
  end
end

```

We have added the [many_to_many](https://hexdocs.pm/ecto/Ecto.Schema.html#many_to_many/3) function.
We've also added in the `changeset` the [unique_constraint](https://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3)
for the `person_id` and `text` values.
We have defined the name of the unique constraint to match the one defined 
in our migration.


In `lib/app/item.ex`, add also the `many_to_many` function to the schema

```elixir
  schema "items" do
    field :person_id, :integer
    field :status, :integer
    field :text, :string

    many_to_many(:tags, Tag, join_through: ItemTag)

    timestamps()
  end
```

Finally  in `lib/app/item_tag.ex`:

```elixir
  @primary_key false
  schema "items_tags" do
    belongs_to(:item, Item)
    belongs_to(:tag, Tag)

    timestamps()
  end
```

Because we have define our `items_tags` migration to not use the default `id`
for the primary we want to reflect this change on the schema by using the
[primary_key false](https://hexdocs.pm/ecto/Ecto.Schema.html#module-schema-attributes) 
schema attribute.

If we don't add this attribute if we attempt
to insert or to get one of the `item_tag` value from the database,
the query will fail as the schema will try to retrieve the non existent `id` column.


We also use the `belongs_to` function to define the association with the `Item` and
`Tag` schemas.


## 11.3 Test tags with Iex

Let's use `iex` to create some items and tags and to check our constraints
are working on the tags

To make our life easier when using `iex` we're going to first create a `.iex.exs`
file containing any aliases you want to have when starting a session:


```elixir
alias App.{Repo, Item, Tag, ItemTag}
```

So when running the Phoenix application `iex -S mix` you will have access
directly to `Repo`, `Item`, `Tag` and `ItemTag`!
see also: https://alchemist.camp/episodes/iex-exs



now run `iex -S mix` and let's create a few items and tags:

```sh
item1 = Repo.insert!(%Item{person_id: 1, text: "item1"})
item2 = Repo.insert!(%Item{person_id: 1, text: "item2"})

tag1 = Repo.insert!(%Tag{person_id: 1, text: "Tag1"})
tag2 = Repo.insert!(%Tag{person_id: 1, text: "Tag2"})
```

We've created two items and two tags, now if we attempt to create "tag1" with the
same person id:

```sh
Repo.insert!(%Tag{person_id: 1, text: "tag1"})

** (Ecto.ConstraintError) constraint error when attempting to insert struct:

    * tags_text_person_id_index (unique_constraint)
```

We can see that the `citext` type is working as "Tag1" and "tag1" can't coexist.

However if we change the person id we can still create the tag:

```sh
Repo.insert!(%Tag{person_id: 2, text: "tag1"})
[debug] QUERY OK db=5.8ms queue=0.1ms idle=1767.0ms
```

We can manually link the tag and the item:

```sh
Repo.insert!{%ItemTag{item_id: item1.id, tag_id: tag1.id})
Repo.delete(item1)
Repo.all(ItemTag)
```

We are creating a link then we delete the item and finally we verify the list
of `ItemTag` is empty. However if we check the list of tags we can see the tag
with id 1 still exist

Finally we can check that we can't add duplicate tags to an item:

```sh
Repo.insert!{%ItemTag{item_id: item2.id, tag_id: tag2.id})
Repo.insert!{%ItemTag{item_id: item2.id, tag_id: tag2.id})
** (Ecto.ConstraintError) constraint error when attempting to insert struct:

    * items_tags_item_id_tag_id_index (unique_constraint)
```


Typing all of this in iex is a slow and if we want to add data to our database
we can use the `priv/repo/seeds.exs` file:

```elixir
alias App.{Repo, Item, Tag, ItemTag}

# reset
Repo.delete_all(Item)
Repo.delete_all(Tag)

item1 = Repo.insert!(%Item{person_id: 1, text: "task1"})
item2 = Repo.insert!(%Item{person_id: 1, text: "task2"})

tag1 = Repo.insert!(%Tag{person_id: 1, text: "tag1"})
tag2 = Repo.insert!(%Tag{person_id: 1, text: "tag2"})

Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag1.id})
Repo.insert!(%ItemTag{item_id: item1.id, tag_id: tag2.id})
Repo.insert!(%ItemTag{item_id: item2.id, tag_id: tag2.id})
```

Then running `mix run priv/repo/seeds.exs` command will populate our database
with our items and tags.

## 11.4 Testing Schemas

We have just tested manually our schemas using Iex, we can also write tests,
for example we can test the changeset for `Tag`:

```elixir
  describe "Test constraints and requirements for Tag schema" do
    test "valid tag changeset" do
      changeset = Tag.changeset(%Tag{}, %{person_id: 1, text: "tag1"})
      assert changeset.valid?
    end

    test "invalid tag changeset when person_id value missing" do
      changeset = Tag.changeset(%Tag{}, %{text: "tag1"})
      refute changeset.valid?
    end

    test "invalid tag changeset when text value missing" do
      changeset = Tag.changeset(%Tag{}, %{person_id: 1})
      refute changeset.valid?
    end
  end
```


see https://hexdocs.pm/phoenix/1.3.2/testing_schemas.html for more information
about testing schemas.

## 11.4  Items-Tags association

We want to create the tags at the same time as the item is created.
The tags are represented as string where tag values are separated by comma:
"tag1, tag2, ..."

So we need first to parse the tags string value, create any new tags in Postgres,
then associate the list of tags to the item.

We'll first update our `Item` schema to add the `on_replace` option to the 
`many_to_many` function:

```elixir
many_to_many(:tags, Tag, join_through: ItemTag, on_replace: :delete)
```

The `:delete` value will remove any associations between the item and the tags that
have been removed, see https://hexdocs.pm/ecto/Ecto.Schema.html#many_to_many/3.


We now create a new changeset:


```elixir
  def changeset_with_tags(item, attrs) do
    changeset(item, attrs)
    |> put_assoc(:tags, Tag.parse_and_create_tags(attrs))
  end
```

The `put_assoc` creates the association between the item and the list of tags.

The `Tag.parse_and_create_tags` function is defined as:

```elixir
  def parse_and_create_tags(attrs) do
    (attrs[:tags] || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> create_tags(attrs[:person_id])
  end
  
  def create_tag(attrs) do
    %Tag{}
    |> changeset(attrs)
    |> Repo.insert()
  end
```

The function makes to parse the tags properly by removing any unwanted value
(ex: empty strings) then it called `create_tags`:

```elixir
  @spec create_tags(tag_name :: list(String.t()), person_id: integer) :: map()
  def create_tags([], _person_id), do: []

  def create_tags(tag_names, person_id) do
    timestamp =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    placeholders = %{timestamp: timestamp}

    maps =
      Enum.map(
        tag_names,
        &%{
          text: &1,
          person_id: person_id,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      )

    Repo.insert_all(
      Tag,
      maps,
      placeholders: placeholders,
      on_conflict: :nothing
    )

    Repo.all(
      from t in Tag, where: t.text in ^tag_names and t.person_id == ^person_id
    )
  end
```

This function uses `Repo.insert_all` to only send one request to insert all the tags.
We need to "build" the tags timestamp as `insert_all` doesn't do this automatically
unlike `Repo.insert`.

The other important information is the `on_conlict` option defined to `:nothing`
in `insert_all`. This means that if we attempt to create a tag which already
exists in the database then we tell Ecto to not raise any error: insert only non
existing tags.

This function is heavily inspired by: https://hexdocs.pm/ecto/constraints-and-upserts.html



Learn more about Ecto with the guides documentation, especially the How to section: 
https://hexdocs.pm/ecto/getting-started.html (taken from: https://dashbit.co/ebooks/the-little-ecto-cookbook)


# 12. Editing timers
In this section we are going to add the ability to edit timers
when editing items. The timer has to follow a specific format 
(`%Y-%m-%d %H:%M:%S`) to be persisted. 

## 12.1 Parsing DateTime strings
As you might have noticed, we are using [NaiveDateTime](https://hexdocs.pm/elixir/1.12/NaiveDateTime.html)
when persisting the timer's datetime.
One would be inclined to use [`from_iso8601/2`](https://hexdocs.pm/elixir/1.14.1/NaiveDateTime.html#from_iso8601/2) 
to parse the input string and convert it to a datetime object. 
However, if we were to think on a long-term perspective,
we would want to be able to parse any string format,
not just `ISO6601`.

Currently, Elixir doesn't have a way to create a datetime object
from any string format. For this, we are going use 
[`Timex`](https://github.com/bitwalker/timex). 
In `mix.exs`, add the following piece of code in the `deps` section.

```elixir
{:timex, "~> 3.7"},
```

and run `mix deps.get`.
This will download and install the package so we can use it.

With this library, we have access to `parse/3` where we can
create a DateTime object from a string according to 
a given format. We are going to be using this later on.

## 12.2 Persisting update in database
So far we can only start, stop and fetch timers. 
We need a way to directly update a specific timer through their `id`.
With this in mind, let's add the update method to 
`lib/app/timer.ex`.

```elixir
  def update_timer(attrs \\ %{}) do
    get_timer!(attrs.id)
    |> changeset(attrs)
    |> Repo.update()
  end
```

In addition to this, we also need a function to fetch
all the timers associated with a specific timer `id`. 
Firstly, let's specify the associations between `Timer` and `Item`.

In `lib/app/timer.ex`, add:

```elixir
  alias App.Item
  import Ecto.Query
```

and inside the `Timers` schema, change the scema to the following.
This will properly reference `Timer` to the `Item` object.

```elixir
  schema "timers" do
    field :start, :naive_datetime
    field :stop, :naive_datetime
    belongs_to :item, Item, references: :id, foreign_key: :item_id

    timestamps()
  end
```

In the same file, let us add a way to list all the timer changesets associated
with a certain `item` id.
We are returning changesets because of form validation.
In case an error occurs, we want to provide feedback to the person.
To do this, we use these changesets and add errors to them, 
which will later be displayed on the UI.
Paste the following.

```elixir
  def list_timers_changesets(item_id) do
    from(v in Timer, where: [item_id: ^item_id], order_by: [asc: :id])
    |> Repo.all()
    |> Enum.map(fn t ->
      Timer.changeset(t, %{
        id: t.id,
        start: t.start,
        stop: t.stop,
        item_id: t.item_id
      })
    end)
  end
```

## 12.3 Adding event handler in `app_live.ex`
We need a way to show the timers related to an `item` in the UI.
Currently, in `lib/app_web/live/app_live.ex`, every time the person
edits an item, an `edit-timer` event is propped up, setting the 
socket assigns accordingly.

We want to fetch the timers of an item *ad-hoc*. Instead of loading
all the timers on mount, it's best to dynamically fetch the timers
whenever we want to edit a timer. For this, we are going to add an
**array of timer changesets** to the socket assigns and show these
when editing a timer. Let's do that.

In `lib/app_web/live/app_live.ex`, in the `mount` function, add
`editing_timers: []` to the list of changesets.

```elixir
     assign(socket,
       items: items,
       editing_timers: [],
       editing: nil,
       filter: "active",
       filter_tag: nil
       ...
```

Let's change the `handle_event` handler for the `edit-item` event
to fetch the timer changesets when editing an item. Change the function 
to the following:

```elixir
  def handle_event("edit-item", data, socket) do
    item_id = String.to_integer(data["id"])

    timers_list_changeset = Timer.list_timers_changesets(item_id)

    {:noreply,
     assign(socket, editing: item_id, editing_timers: timers_list_changeset)}
  end
```

Likewise, inside the `handle_event` handler for the `update-item` event,
change the **last line** to reset the `editing_timers` array to empty. This
is after a successful item edit.

```elixir
{:noreply, assign(socket, editing: nil, editing_timers: [])}
```

Now we need to have an handler for an event that will be created
when editing a timer. For this, create the following function 
in the same file.

```elixir
  @impl true
  def handle_event(
        "update-item-timer",
        %{
          "timer_id" => id,
          "index" => index,
          "timer_start" => timer_start,
          "timer_stop" => timer_stop
        },
        socket
      ) do

    timer_changeset_list = socket.assigns.editing_timers
    index = String.to_integer(index)

    timer = %{
      id: id,
      start: timer_start,
      stop: timer_stop
    }

    case Timer.update_timer_inside_changeset_list( timer, index, timer_changeset_list) do
      {:ok, _list} -> 
        # Updates item list and broadcast to other clients
        AppWeb.Endpoint.broadcast(@topic, "update", :update)
        {:noreply, assign(socket, editing: nil, editing_timers: [])}

      {:error, updated_errored_list} -> 
        {:noreply, assign(socket, editing_timers: updated_errored_list)}
    end
  end
```

Let's do a rundown of what we just added. 
From the form, we receive an `index` of the timer inside the `editing_timers`
socket assign array. We use this `index` to replace the changeset being edited
in case there's an error with the string format or the dates. 

We are calling a function `update_timer_inside_changeset_list/5`
that we will implement shortly, This function will either
update the timer successfully or return an error, 
with an updated list of timer changesets to display the error on the UI.

We want the `people` to be able to update `timers` even when 
there's an ongoing timer and have the `people` still 
see the list of `timers`.
For this, we ought to update the events that are created
when clicking `Resume` or `Stop`. 
Therefore, we need to these handlers and the broadcast
`update` event that is sent to all connected clients.

Let's check the `start` and `stop` event handlers inside `app_live.ex`.
Let's add information to the event with the `item.id` that is being edited.
Change these event handlers so they look like this.

```elixir
  @impl true
  def handle_event("start", data, socket) do
    item = Item.get_item!(Map.get(data, "id"))
    person_id = get_person_id(socket.assigns)

    {:ok, _timer} =
      Timer.start(%{
        item_id: item.id,
        person_id: person_id,
        start: NaiveDateTime.utc_now()
      })

    AppWeb.Endpoint.broadcast(@topic, "update", {:start, item.id})
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", data, socket) do
    timer_id = Map.get(data, "timerid")
    {:ok, _timer} = Timer.stop(%{id: timer_id})

    AppWeb.Endpoint.broadcast(@topic, "update", {:stop, Map.get(data, "id")})
    {:noreply, socket}
  end
```

Now we need to update the `handle_info/2` event handler
that deals with this broadcasting event that is used 
everytime `Start/Resume` or `Stop` is called.

```elixir
  @impl true
  def handle_info(%Broadcast{event: "update", payload: payload}, socket) do
    person_id = get_person_id(socket.assigns)
    items = Item.items_with_timers(person_id)

    isEditingItem = socket.assigns.editing

    # If the item is being edited, we update the timer list of the item being edited.
    if isEditingItem do
      case payload do
        {:start, item_id} ->
          timers_list_changeset = Timer.list_timers_changesets(item_id)

          {:noreply,
           assign(socket,
             items: items,
             editing: item_id,
             editing_timers: timers_list_changeset
           )}

        {:stop, item_id} ->
          timers_list_changeset = Timer.list_timers_changesets(item_id)

          {:noreply,
           assign(socket,
             items: items,
             editing: item_id,
             editing_timers: timers_list_changeset
           )}

        _ ->
          {:noreply, assign(socket, items: items)}
      end

      # If not, just update the item list.
    else
      {:noreply, assign(socket, items: items)}
    end
  end
```

Now, everytime the `update` event is broadcasted,
we update the timer list if the item is being edited.
If not, we update the timer list, as normally.
What this does is that every person will have the `socket.assigns`
properly updated everytime a timer is edited.


## 12.4 Updating timer changeset list on `timer.ex`
Let's create the unimplemented function that we 
previously added. 
In the `timer.ex` file, add the following.

```elixir
def update_timer_inside_changeset_list(
    %{
      id: timer_id,
      start: timer_start,
      stop: timer_stop
    },
    index,
    timer_changeset_list
  ) when timer_stop == "" or timer_stop == nil do

    # Getting the changeset to change in case there's an error
    changeset_obj = Enum.at(timer_changeset_list, index)

    try do

      # Parsing the dates
      {start_op, start} =
        Timex.parse(timer_start, "%Y-%m-%dT%H:%M:%S", :strftime)

      # Error guards when parsing the date
      if start_op === :error do
        throw(:error_invalid_start)
      end

      # Getting a list of the other timers (the rest we aren't updating)
      other_timers_list = List.delete_at(timer_changeset_list, index)

      # If there are other timers, we check if there are no overlap
      if(length(other_timers_list) > 0) do

        # Latest timer end
        max_end =
          other_timers_list |> Enum.map(fn chs -> chs.data.stop end) |> Enum.max()

        case NaiveDateTime.compare(start, max_end) do
          :gt ->
            timer = get_timer(timer_id)
            update_timer(timer, %{start: start, stop: nil})
            {:ok, []}

          _ ->
            throw(:error_not_after_others)
        end

      # If there are no other timers, we can update the timer safely
      else
        timer = get_timer(timer_id)
        update_timer(timer, %{start: start, stop: nil})
        {:ok, []}
      end

    catch
      :error_invalid_start ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Start field has an invalid date format.",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_not_after_others ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "When editing an ongoing timer, make sure it's after all the others.",
            :update
          )

        {:error, updated_changeset_timers_list}
    end
  end
  def update_timer_inside_changeset_list(
        %{
          id: timer_id,
          start: timer_start,
          stop: timer_stop
        },
        index,
        timer_changeset_list
      ) do

    # Getting the changeset to change in case there's an error
    changeset_obj = Enum.at(timer_changeset_list, index)

    try do

      # Parsing the dates
      {start_op, start} =
        Timex.parse(timer_start, "%Y-%m-%dT%H:%M:%S", :strftime)

      {stop_op, stop} = Timex.parse(timer_stop, "%Y-%m-%dT%H:%M:%S", :strftime)

      # Error guards when parsing the dates
      if start_op === :error do
        throw(:error_invalid_start)
      end

      if stop_op === :error do
        throw(:error_invalid_stop)
      end

      case NaiveDateTime.compare(start, stop) do
        :lt ->

          # Creates a list of all other timers to check for overlap
          other_timers_list = List.delete_at(timer_changeset_list, index)

          # Timer overlap verification ---------
          for chs <- other_timers_list do
            chs_start = chs.data.start
            chs_stop = chs.data.stop

            # If the timer being compared is ongoing
            if chs_stop == nil do
              compareStart = NaiveDateTime.compare(start, chs_start)
              compareEnd = NaiveDateTime.compare(stop, chs_start)

              # The condition needs to FAIL so the timer doesn't overlap
              if compareStart == :lt && compareEnd == :gt do
                throw(:error_overlap)
              end

              # Else the timer being compared is historical
            else
              # The condition needs to FAIL (StartA <= EndB) and (EndA >= StartB)
              # so no timer overlaps one another
              compareStartAEndB = NaiveDateTime.compare(start, chs_stop)
              compareEndAStartB = NaiveDateTime.compare(stop, chs_start)

              if(
                (compareStartAEndB == :lt || compareStartAEndB == :eq) &&
                  (compareEndAStartB == :gt || compareEndAStartB == :eq)
              ) do
                throw(:error_overlap)
              end
            end
          end

          update_timer(%{id: timer_id, start: start, stop: stop})
          {:ok, []}

        :eq ->
          throw(:error_start_equal_stop)

        :gt ->
          throw(:error_start_greater_than_stop)
      end
    catch
      :error_invalid_start ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Start field has an invalid date format.",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_invalid_stop ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Stop field has an invalid date format.",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_overlap ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "This timer interval overlaps with other timers. Make sure all the timers are correct and don't overlap with each other",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_start_equal_stop ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Start or stop are equal.",
            :update
          )

        {:error, updated_changeset_timers_list}

      :error_start_greater_than_stop ->
        updated_changeset_timers_list =
          Timer.error_timer_changeset(
            timer_changeset_list,
            changeset_obj,
            index,
            :id,
            "Start is newer that stop.",
            :update
          )

        {:error, updated_changeset_timers_list}
    end
  end
```

That is a lot of code! But it's fairly simple.
Firstly, these two functions are called according to 
pattern matching of the `timer_stop` field. 
If `timer_stop` field is empty, we assume it's an 
ongoing timer being edited. 
If both `timer_start` and `timer_stop` is being edited,
it's because the person is changing an old timer. 

Inside both functions, the flow is the same.
We first get the *timer changeset* being edited
by using the `index` parameter and the passed changeset list.
After this, we try to parse the field using `Timex`.
If this doesn't work, we **throw an error**. 
All of errors thrown are later caught.

If the parse is successful, we compare the
`start` and `stop` fields and check if the `start`
is newer than `stop` or if they're equal. 
This is not allowed, so we throw an error if this is the case.

If these verifications are passed, in the case of
*ongoing timers*, we check if the timer `start` being edited
is **after all the timers**. 
In the case of *old timer being updated*, 
we check if there is an overlap with the rest of the timers.

If all of these validations are successful,
the timer is updated. 
If not, the error that was thrown is caught 
using `catch`. 
Depending on the error, we add a different error text 
to be displayed on the form and then return the error.

In each error, we make use of the `error_timer_changeset/6`
function, which just replaces the timer inside the list
with a custom error to be displayed on the form.
Let's add this function.

```elixir
  def error_timer_changeset(
        timer_changeset_list,
        changeset_to_error,
        changeset_index,
        error_key,
        error_message,
        action
      ) do
    # Clearing and adding error to changeset
    cleared_changeset = Map.put(changeset_to_error, :errors, [])

    errored_changeset =
      Ecto.Changeset.add_error(
        cleared_changeset,
        error_key,
        error_message
      )

    {_reply, errored_changeset} =
      Ecto.Changeset.apply_action(errored_changeset, action)

    #  Updated list with errored changeset
    List.replace_at(timer_changeset_list, changeset_index, errored_changeset)
  end
```

And now all that's left is to change the UI! Let's do that.

## 12.5 Updating the UI
Now let's focus on showing the timers in the UI. Head over to
`lib/app_web/live/app_live.html.heex` and make the following changes.
We are showing each timer whenever an `item` is being edited.

```html
<%= if item.id == @editing do %>

<!-- Replace starts here -->

  <div class="flex flex-col grow">
    <form
      phx-submit="update-item"
      id={"form-update-item-#{item.id}"}
      class="w-full pr-2"
    >
      <textarea
        id={"textarea-editing-of-item-#{item.id}"}
        class="w-full flex-auto text-slate-800
      bg-white bg-clip-padding
      transition ease-in-out
      border border-b border-slate-200
      focus:border-none focus:outline-none"
        name="text"
        placeholder="What is on your mind?"
        autofocus
        required="required"
        value={item.text}
      ><%= item.text %></textarea>
      <input
        id={"tag-of-item-#{item.id}"}
        type="text"
        name="tags"
        value={tags_to_string(item.tags)}
        placeholder="tag1, tag2..."
      />

      <input type="hidden" name="id" value={item.id} />

      <div
        class="flex justify-end mr-1"
        id={"save-button-item-#{item.id}"}
      >
        <button class="inline-flex items-center px-2 py-1 mt-1 h-9
      bg-green-700 hover:bg-green-800 text-white rounded-md">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-5 w-5 mr-2"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 13l-3 3m0 0l-3-3m3 3V8m0 13a9 9 0 110-18 9 9 0 010 18z"
            />
          </svg>
          Save
        </button>
      </div>
    </form>

    <div>
      <%= if (length @editing_timers) > 0 do %>
        <h1 class="text-4xl font-bold">Timers</h1>
      <% else %>
        <h1 class="text-2xl text-center font-semibold text-slate-400">
          No timers associated with this item.
        </h1>
      <% end %>

      <div class="flex flex-col w-full mt-2">
        <%= @editing_timers |> Enum.with_index |> Enum.map(fn({changeset, index}) -> %>
          <.form
            :let={f}
            for={changeset}
            phx-submit="update-item-timer"
            id={"form-update-timer-#{changeset.data.id}"}
            class="w-full pr-2"
          >
            <div class="flex flex-row w-full justify-between">
              <div class="flex flex-row items-center">
                <h3 class="mr-3">Start:</h3>
                <input
                  type="text"
                  required="required"
                  name="timer_start"
                  id={"#{changeset.data.id}_start"}
                  value={
                    NaiveDateTime.add(
                      changeset.data.start,
                      @hours_offset_fromUTC,
                      :hour
                    )
                  }
                />
              </div>
              <div class="flex flex-row items-center">
                <h3 class="mr-3">Stop:</h3>
                <input
                  type="text"
                  name="timer_stop"
                  id={"#{changeset.data.id}_stop"}
                  value={
                    if is_nil(changeset.data.stop) do
                      changeset.data.stop
                    else
                      NaiveDateTime.add(
                        changeset.data.stop,
                        @hours_offset_fromUTC,
                        :hour
                      )
                    end
                  }
                />
              </div>
              <input
                type="hidden"
                name="timer_id"
                value={changeset.data.id}
              />
              <input type="hidden" name="index" value={index} />

              <button
                type="submit"
                id={"button_timer-update-#{changeset.data.id}"}
                class="text-white bg-blue-700
                  hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-300
                  font-medium rounded-full text-sm px-5 py-2.5 text-center
                  mr-2 mb-2
                    dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
              >
                Update
              </button>
            </div>
            <span class="text-red-700">
              <%= error_tag(f, :id) %>
            </span>
          </.form>
        <% end) %>
      </div>
    </div>
  </div>

<!-- Replace ends here -->

<% else %>
<!-- Render item.text as click-able label -->

```

As you can see from the snippet above, 
for each timer related to an `item`, 
we are creating a form.
When the changes from the form are submitted, a 
`update-item-timer` event is created. 
With this event, all the fields added inside
the form is passed on (the timer `id`,
`index` inside the timer changesetlist,
`timer_start` and `timer_stop`)

## 12.6 Updating the tests and going back to 100% coverage

If we run `source .env_sample` and
`MIX_ENV=test mix coveralls.html ; open cover/excoveralls.html`
we will see how coverage dropped. 
We need to test the new handler we created when updating a timer,
as well as the `update_timer` function added inside `timer.ex`.

Paste the following test in `test/app/timer_test.exs`.

```elixir
    test "update_timer(%{id: id, start: start, stop: stop}) should update the timer" do
      start = ~N[2022-10-27 00:00:00]
      stop = ~N[2022-10-27 05:00:00]

      {:ok, item} = Item.create_item(@valid_item_attrs)

      {:ok, seven_seconds_ago} =
        NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

      # Start the timer 7 seconds ago:
      {:ok, timer} =
        Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

      # Stop the timer based on its item_id
      Timer.stop_timer_for_item_id(item.id)

      # Update timer to specific datetimes
      Timer.update_timer(%{id: timer.id, start: start, stop: stop})

      updated_timer = Timer.get_timer!(timer.id)

      assert updated_timer.start == start
      assert updated_timer.stop == stop
    end
```

We now test the newly created `update-item-timer` event. 
In `test/app_web/live/app_live_test.exs`, add the following test.

```elixir
test "update an item's timer", %{conn: conn} do
    start = "2022-10-27T00:00:00"
    stop = "2022-10-27T05:00:00"
    start_datetime = ~N[2022-10-27 00:00:00]
    stop_datetime = ~N[2022-10-27 05:00:00]

    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    {:ok, view, _html} = live(conn, "/")

    # Update successful
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => start,
             "timer_stop" => stop
           })

    updated_timer = Timer.get_timer!(timer.id)

    assert updated_timer.start == start_datetime
    assert updated_timer.stop == stop_datetime

    # Trying to update with equal values on start and stop
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => start,
             "timer_stop" => start
           }) =~ "Start or stop are equal."

    # Trying to update with equal start greater than stop
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => stop,
             "timer_stop" => start
           }) =~ "Start is newer that stop."

    # Trying to update with start as invalid format
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => "invalid",
             "timer_stop" => stop
           }) =~ "Start field has an invalid date format."

    # Trying to update with stop as invalid format
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    assert render_submit(view, "update-item-timer", %{
              "timer_id" => timer.id,
              "index" => 0,
              "timer_start" => start,
              "timer_stop" => "invalid"
            }) =~ "Stop field has an invalid date format."
  end
```

We also need to change the `test "edit-timer"` test because it's failing.
We have changed the id of the form when changing the `.heex` template.
Change the test to the following.

```elixir
  test "edit-item", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})
    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)}) =~
             "<form phx-submit=\"update-item\" id=\"form-update"
  end
```

Let's add more tests for the edge cases. 
Let's test ongoing timers and overlapping :smile:
In the same `test_live_test.exs` file, 
add the following tests.

```elixir
test "update timer timer with ongoing timer ", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    {:ok, now} = NaiveDateTime.new(Date.utc_today(), Time.utc_now())

    {:ok, four_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -4))

    {:ok, ten_seconds_after} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), 10))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    # Start a second timer
    {:ok, timer2} = Timer.start(%{item_id: item.id, person_id: 1, start: now})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    {:ok, view, _html} = live(conn, "/")

    # Update fails because of overlap timer -----------
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    four_seconds_ago_string =
      NaiveDateTime.truncate(four_seconds_ago, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    now_string =
      NaiveDateTime.truncate(now, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    error_view =
      render_submit(view, "update-item-timer", %{
        "timer_id" => timer2.id,
        "index" => 1,
        "timer_start" => four_seconds_ago_string,
        "timer_stop" => ""
      })

    assert error_view =~ "When editing an ongoing timer"

    # Update fails because of format -----------
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    error_format_view =
      render_submit(view, "update-item-timer", %{
        "timer_id" => timer2.id,
        "index" => 1,
        "timer_start" => "invalidformat",
        "timer_stop" => ""
      })

    assert error_format_view =~ "Start field has an invalid date format."

    # Update successful -----------
    ten_seconds_after_string =
      NaiveDateTime.truncate(ten_seconds_after, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    ten_seconds_after_datetime =
      NaiveDateTime.truncate(ten_seconds_after, :second)

    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    view =
      assert render_submit(view, "update-item-timer", %{
               "timer_id" => timer2.id,
               "index" => 1,
               "timer_start" => ten_seconds_after_string,
               "timer_stop" => ""
             })

    updated_timer2 = Timer.get_timer!(timer2.id)

    assert updated_timer2.start == ten_seconds_after_datetime
  end

  test "timer overlap error when updating timer", %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    {:ok, now} = NaiveDateTime.new(Date.utc_today(), Time.utc_now())

    {:ok, four_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -4))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    # Start a second timer
    {:ok, timer2} = Timer.start(%{item_id: item.id, person_id: 1, start: now})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    {:ok, view, _html} = live(conn, "/")

    # Update fails because of overlap -----------
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    four_seconds_ago_string =
      NaiveDateTime.truncate(four_seconds_ago, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    now_string =
      NaiveDateTime.truncate(now, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer2.id,
             "index" => 0,
             "timer_start" => four_seconds_ago_string,
             "timer_stop" => now_string
           }) =~ "This timer interval overlaps with other timers."
  end

  test "timer overlap error when updating historical timer with ongoing timer",
       %{conn: conn} do
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    {:ok, now} = NaiveDateTime.new(Date.utc_today(), Time.utc_now())

    {:ok, twenty_seconds_future} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), 20))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    # Start a second timer
    {:ok, timer2} = Timer.start(%{item_id: item.id, person_id: 1, start: now})

    {:ok, view, _html} = live(conn, "/")

    # Update fails because of overlap -----------
    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    seven_seconds_ago_string =
      NaiveDateTime.truncate(seven_seconds_ago, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    twenty_seconds_string =
      NaiveDateTime.truncate(twenty_seconds_future, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    assert render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => seven_seconds_ago_string,
             "timer_stop" => twenty_seconds_string
           }) =~ "This timer interval overlaps with other timers."
  end
```

Let us not forget we also changed the way 
the `update` event is broadcasted. 
It now updates the socket assigns depending
on whether an item is being edited or not. 
Let's add tests in the same file to cover these scenarios

```elixir
test "handle_info/2 update with editing open (start)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} =
      Item.create_item(%{text: "Always Learning", person_id: 0, status: 2})

    {:ok, now} = NaiveDateTime.new(Date.utc_today(), Time.utc_now())

    now_string =
      NaiveDateTime.truncate(now, :second)
      |> NaiveDateTime.to_string()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        if index == 10 do
          "T"
        else
          value
        end
      end)
      |> List.to_string()

    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})
    render_click(view, "start", %{"id" => Integer.to_string(item.id)})

    # The editing panel is open and showing the newly created timer on the 'Start' text input field
    assert render(view) =~ now_string
  end

  test "handle_info/2 update with editing open (stop)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} =
      Item.create_item(%{text: "Always Learning", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})
    render_click(view, "start", %{"id" => Integer.to_string(item.id)})
    render_click(view, "stop", %{"timerid" => timer.id, "id" => item.id})

    num_timers_rendered =
      (render(view) |> String.split("Update") |> length()) - 1

    # Checking if two timers were rendered
    assert num_timers_rendered == 2
  end

  test "handle_info/2 update with editing open (delete)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, item} =
      Item.create_item(%{text: "Always Learning", person_id: 0, status: 2})

    render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    send(view.pid, %Broadcast{
      event: "update",
      payload: :delete
    })

    assert render(view) =~ item.text
  end
```


Having a page to track metrics 
regarding app usage is important two-fold:
- if you are a **developer**, 
it's crucial to know if and how the app is being used,
to better implement features in the future.
- if you are a **`person`**, 
you want to view aggregate stats of how many 
`items` and `timers` you created
so you know how to improve your personal effectiveness.

Let's create a simple `/stats` dashboard
to display the number of `items` and `timers` each `person` has created
in a simple table.

Let's roll!


Open 
`lib/app_web/router.ex` 
and add the new route inside the `"/"` scope.

```elixir
    ...

    get "/login", AuthController, :login
    get "/logout", AuthController, :logout

    live "/stats", StatsLive
```

Now create the `StatsLive` file
with the path:
`lib/app_web/live/stats_live.ex`
and template at:
`lib/app_web/live/stats_live.html.heex`.

In `stats_live.ex`,
paste the following code:

```elixir
defmodule AppWeb.StatsLive do
  require Logger
  use AppWeb, :live_view
  alias App.Item
  alias Phoenix.Socket.Broadcast

  # run authentication on mount
  on_mount(AppWeb.AuthController)

  @stats_topic "stats"

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@stats_topic)

    metrics = Item.person_with_item_and_timer_count()

    {:ok,
     assign(socket,
       metrics: metrics
     )}
  end

  @impl true
  def handle_info(
        %Broadcast{topic: @stats_topic, event: "item", payload: payload},
        socket
      ) do
    metrics = socket.assigns.metrics

    case payload do
      {:create, payload: payload} ->
        updated_metrics = Enum.map(metrics, fn row -> add_row(row, payload, :num_items) end)

        {:noreply, assign(socket, metrics: updated_metrics)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        %Broadcast{topic: @stats_topic, event: "timer", payload: payload},
        socket
      ) do
    metrics = socket.assigns.metrics

    case payload do
      {:create, payload: payload} ->
        updated_metrics = Enum.map(metrics, fn row -> add_row(row, payload, :num_timers) end)

        {:noreply, assign(socket, metrics: updated_metrics)}

      _ ->
        {:noreply, socket}
    end
  end

  def add_row(row, payload, key) do
    row =
      if row.person_id == payload.person_id do
        Map.put(row, key, Map.get(row, key) + 1)
      else
        row
      end

    row
  end

  def person_link(person_id) do
    "https://auth.dwyl.com/people/#{person_id}"
  end
end
```

Let's break this down.
On `mount`, we are retrieving 
an array containing the number of items and timers of each person (`id` and `name`).
We are calling `Item.person_with_item_and_timer_count()` for this
(we will implement this right after this, don't worry!).

This `LiveView` is subscribed to a channel called `stats`,
and has two handlers which increment the number of `timers` or `items` 
in real-time whenever a `person` joins.
For this to actually work, 
we need to broadcast to this channel. 

`person_link/1` is merely used to display their 
profile in [`auth.dwyl.com`](https://auth.dwyl.com)

We will do this shortly!
But first, let's implement `Item.person_with_item_and_timer_count()`.


In `lib/app/item.ex`,
add the following function.

```elixir
  def person_with_item_and_timer_count() do
    sql = """
    SELECT i.person_id,
    COUNT(distinct i.id) AS "num_items",
    COUNT(distinct t.id) AS "num_timers"
    FROM items i
    LEFT JOIN timers t ON t.item_id = i.id
    GROUP BY i.person_id
    ORDER BY i.person_id
    """

    Ecto.Adapters.SQL.query!(Repo, sql)
    |> map_columns_to_values()

  end
```

We are simply executing an SQL query expression
and retrieving it.
This function should yield a list of objects 
containing `person_id`, `name`, `num_items` and `num_timers`.

```elixir
[
  %{name: nil, num_items: 3, num_timers: 8, person_id: 0}
  %{name: username, num_items: 1, num_timers: 3, person_id: 1}
]
```


We've created `lib/app_web/live/stats_live.html.heex`
but haven't implemented anything.
Let's fix that now.

Add this code to the file.

```html
<main class="font-sans container mx-auto">
    <div class="relative overflow-x-auto mt-12">
        <h1 class="mb-12 text-xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
            Usage metrics
        </h1>
        <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
          <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
            <tr>
              <th scope="col" class="px-6 py-3">
                Id
              </th>
              <th scope="col" class="px-6 py-3">
                Number of items
              </th>
              <th scope="col" class="px-6 py-3">
                Number of timers
              </th>
            </tr>
          </thead>
          <tbody>
          <%= for metric <- @metrics do %>
            <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
              <td class="px-6 py-4">
                <a href={person_link(metric.person_id)}>
                  <%= metric.person_id %>
                </a>
              </td>
              <td class="px-6 py-4">
                <%= metric.num_items %>
              </td>
              <td class="px-6 py-4">
                <%= metric.num_timers %>
              </td>
            </tr>
          <% end %>
          </tbody>
        </table>
    </div>
</main>
```

We are simply creating a table with four columns,
one for `person_id`, person `name`, number of `items` and number of `timers`.
We are accessing the `@metrics` array 
that is fetched and assigned on `mount/3` inside `stats_live.ex`.


The only thing that is left to implement 
is broadcasting events from `lib/app_web/live/app_live.ex`
so `stats_live.ex` handles them and updates `stats_live.html.heex` accordingly.

In `lib/app_web/live/app_live.ex`,
let's create a new constant value 
for the `stats` channel.

```elixir
@topic "live"
@stats_topic "stats" # add this
```

Whenever an `item` or `timer` is created,
an event is going to be broadcasted to this channel.

Let's subscribe to the `stats` channel on mount,
similarly to what happens with `live`.
In `mount/3`,
subscribe to the `stats` channel
like we are doing to the `live` one.

```elixir
if connected?(socket), do:
  AppWeb.Endpoint.subscribe(@topic)
  AppWeb.Endpoint.subscribe(@stats_topic)
```

Now, in the 
`handle_event("create", %{"text" => text}, socket)` function,
broadcast an event to the `stats` channel
whenever an `item` is created.

```elixir
def handle_event("create", %{"text" => text}, socket) do
  person_id = get_person_id(socket.assigns)

  Item.create_item_with_tags(%{
    text: text,
    person_id: person_id,
    status: 2,
    tags: socket.assigns.selected_tags
  })

  AppWeb.Endpoint.broadcast(@topic, "update", :create)
  AppWeb.Endpoint.broadcast(@stats_topic, "item", {:create, payload: %{person_id: person_id}}) # add this
  {:noreply, assign(socket, text_value: "", selected_tags: [])}
end
```

Similarly, do the same for `timers`.

```elixir
def handle_event("start", data, socket) do
  item = Item.get_item!(Map.get(data, "id"))
  person_id = get_person_id(socket.assigns)

  {:ok, _timer} =
    Timer.start(%{
      item_id: item.id,
      person_id: person_id,
      start: NaiveDateTime.utc_now()
    })

  AppWeb.Endpoint.broadcast(@topic, "update", {:start, item.id})
  AppWeb.Endpoint.broadcast(@stats_topic, "timer", {:create, payload: %{person_id: person_id}}) # add this
  {:noreply, socket}
end
```

In the same file,
`app_live.ex` 
also needs to have a handler
of these new event broadcasts,
or else an error is thrown.

```sh
no function clause matching in AppWeb.AppLive.handle_info/2
```

`app_live.ex` doesn't really care about these events,
so we do nothing with them.
Add the following function for this.

```elixir
@impl true
def handle_info(%Broadcast{topic: @stats_topic, event: _event, payload: _payload}, socket) do
  {:noreply, socket}
end

```


Let's add the tests to cover the use case
we just created.

Firstly, let's create a file:
`test/app_web/live/stats_live_test.exs`
and add the following code to it.

```elixir
defmodule AppWeb.StatsLiveTest do
  use AppWeb.ConnCase
  alias App.{Item, Person, Timer, Tag}
  import Phoenix.LiveViewTest
  alias Phoenix.Socket.Broadcast

  @person_id 55

  setup [:create_person]

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/stats")
    assert disconnected_html =~ "Usage metrics"
    assert render(page_live) =~ "Usage metrics"
  end

  test "display metrics on mount", %{conn: conn} do
    # Creating two items
    {:ok, item} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, _item2} =
      Item.create_item(%{text: "Learn Elixir", status: 4, person_id: @person_id})

    assert item.status == 2

    # Creating one timer
    started = NaiveDateTime.utc_now()
    {:ok, _timer} = Timer.start(%{item_id: item.id, start: started})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # two items and one timer expected
    assert render(page_live) =~
    "<td class=\"px-6 py-4 text-center\">\n2\n            </td><td class=\"px-6 py-4 text-center\">\n1\n            </td>"
  end

  test "handle broadcast when item is created", %{conn: conn} do
    # Creating an item
    {:ok, _item} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # num of items
    assert render(page_live) =~
    "<td class=\"px-6 py-4 text-center\">\n1\n            </td><td class=\"px-6 py-4 text-center\">\n0\n            </td>"

    # Creating another item.
    AppWeb.Endpoint.broadcast(
      "stats",
      "item",
      {:create, payload: %{person_id: @person_id}}
    )

    # num of items
    assert render(page_live) =~
      "<td class=\"px-6 py-4 text-center\">\n2\n            </td><td class=\"px-6 py-4 text-center\">\n0\n            </td>"


    # Broadcasting update. Shouldn't effect anything in the page
    AppWeb.Endpoint.broadcast(
      "stats",
      "item",
      {:update, payload: %{person_id: @person_id}}
    )

    # num of items
    assert render(page_live) =~
      "<td class=\"px-6 py-4 text-center\">\n2\n            </td><td class=\"px-6 py-4 text-center\">\n0\n            </td>"
  end

  test "handle broadcast when timer is created", %{conn: conn} do
    # Creating an item
    {:ok, _item} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # num of timers
    assert render(page_live) =~
    "<td class=\"px-6 py-4 text-center\">\n1\n            </td><td class=\"px-6 py-4 text-center\">\n0\n            </td>"

    # Creating a timer.
    AppWeb.Endpoint.broadcast(
      "stats",
      "timer",
      {:create, payload: %{person_id: @person_id}}
    )

    # num of timers
    assert render(page_live) =~
    "<td class=\"px-6 py-4 text-center\">\n1\n            </td><td class=\"px-6 py-4 text-center\">\n1\n            </td>"

    # Broadcasting update. Shouldn't effect anything in the page
    AppWeb.Endpoint.broadcast(
      "stats",
      "timer",
      {:update, payload: %{person_id: @person_id}}
    )

    # num of timers
    assert render(page_live) =~
    "<td class=\"px-6 py-4 text-center\">\n1\n            </td><td class=\"px-6 py-4 text-center\">\n1\n            </td>"
  end

  test "add_row/3 adds 1 to row.num_timers" do
    row = %{person_id: 1, num_items: 1, num_timers: 1}
    payload = %{person_id: 1}

    # expect row.num_timers to be incremented by 1:
    row_updated = AppWeb.StatsLive.add_row(row, payload, :num_timers)
    assert row_updated == %{person_id: 1, num_items: 1, num_timers: 2}

    # no change expected:
    row2 = %{person_id: 2, num_items: 1, num_timers: 42}
    assert row2 == AppWeb.StatsLive.add_row(row2, payload, :num_timers)
  end
end
```

We've now covered the `stats_live.ex` file thoroughly.
The *last* thing we need to do
is to add a test for the `person_with_item_and_timer_count/0`
function that was implemented inside `lib/app/item.ex`.

Open `test/app/item_test.exs`
and add this test.

```elixir
  test "Item.person_with_item_and_timer_count/0 returns a list of count of timers and items for each given person" do
    {:ok, item1} = Item.create_item(@valid_attrs)
    {:ok, item2} = Item.create_item(@valid_attrs)

    started = NaiveDateTime.utc_now()

    {:ok, timer1} =
      Timer.start(%{
        item_id: item1.id,
        person_id: item1.person_id,
        start: started,
        stop: started
      })

    {:ok, _timer2} =
      Timer.start(%{item_id: item2.id, person_id: item2.person_id, start: started})

    # list person with number of timers and items
    person_with_items_timers = Item.person_with_item_and_timer_count()

    assert length(person_with_items_timers) == 1

    first_element = Enum.at(person_with_items_timers, 0)

    assert Map.get(first_element, :num_items) == 2
    assert Map.get(first_element, :num_timers) == 2
  end
```


And you're done!
Awesome job! 🎉
If you run `mix phx.server`,
you should see `/stats` being updated **live** 
when creating `timers` or `items`.

![stats_final](https://user-images.githubusercontent.com/17494745/211345854-c541d21c-4289-4576-8fcf-c3b89251ed02.gif)

# 13. Tracking changes of `items` in database

Tracking changes that each `item` is subjected to
over time is important not only for statistics
but to also implement features 
that such as *rolling back changes*.

For this, we are going to be using 
[`PaperTrail`](https://github.com/dwyl/phoenix-papertrail-demo/blob/main/lib/app/change.ex),
which makes it easy for us to record each change 
on each `item` transaction occurred in the database.

In this section we are going to explain
the process of implementing this feature.
Some of these steps overlap 
[`phoenix-papertrail-demo`](https://github.com/dwyl/phoenix-papertrail-demo)'s.
If you are interested in a more in-depth tutorial,
we recommend you take a gander there!

## 13.1 Setting up

Install `paper_trail`.

```elixir
def deps do
[
  ...
  {:paper_trail, "~> 0.14.3"}
]
end
```

And add this config to `config/config.exs`.

```elixir
config :paper_trail, repo: App.Repo
```

This will let `PaperTrail` know the reference of the database repo,
so it can sabe the changes correctly.

After this, run the following commands.

```sh
mix deps.get
mix compile
mix papertrail.install
```

This will install dependencies, compile the project
and create a migration for creating the `versions` table.
This will be the table where all the changes will be recorded.

If you open the created migration in
`priv/repo/migrations/XXX_add_versions.exs`,
you will find the schema for te table.

```elixir
    create table(:versions) do
      add :event,        :string, null: false, size: 10
      add :item_type,    :string, null: false
      add :item_id,      :integer
      add :item_changes, :map, null: false
      add :originator_id, references(:users) # you can change :users to your own foreign key constraint
      add :origin,       :string, size: 50
      add :meta,         :map

      # Configure timestamps type in config.ex :paper_trail :timestamps_type
      add :inserted_at,  :utc_datetime, null: false
    end
```

You can find more information about what field means
in [`phoenix-papertrail-demo`](https://github.com/dwyl/phoenix-papertrail-demo).
We are going to be changing the `originator_id` to the following line.

```elixir
add :originator_id, :integer
```

The `originator_id` refers to "who made this change".
In the case of our application, 
we want to use the `person_id` that is used when logging in 
with a third-party provider.

Do note that **we do not save a person's information**.
So the `person_id` will need to be passed each time
a CRUD operation occurs 
(or not, if the operation is anonymous).

## 13.2 Changing database transactions on `item` insert and update

We want to track the changes when an `item` is inserted or updated.
To do this,
we can use `PaperTrail.insert` and `PaperTrail.update` methods.
We are going to replace `Repo.insert` and `Repo.update` functions
with these.

Head over to `lib/app/item.ex`,
add the import 
and make these changes in `create_item/1`,
`create_item_with_tags/1`
and `update_item/2`.

```elixir
alias PaperTrail

  def create_item(attrs) do
    %Item{}
    |> changeset(attrs)
    |> PaperTrail.insert(originator: %{id: Map.get(attrs, :person_id, 0)})
  end

  def create_item_with_tags(attrs) do
    %Item{}
    |> changeset_with_tags(attrs)
    |> PaperTrail.insert(originator: %{id: Map.get(attrs, :person_id, 0)})
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> PaperTrail.update(originator: %{id: Map.get(attrs, :person_id, 0)})
  end
```

We are using the `person_id` 
and using it to be placed in the `originator_id` column
in the `Versions` table.
If no `person_id` is passed, 
we default to `id=0`.

We want to successfully pass the `person_id` 
when the item is toggled, as well.
In `lib/app_web/live/app_live.ex`,
in `handle_event("toggle", data, socket)`,
update it so it looks like the following:

```elixir
  @impl true
  def handle_event("toggle", data, socket) do
    person_id = get_person_id(socket.assigns)

    # Toggle the status of the item between 3 (:active) and 4 (:done)
    status = if Map.has_key?(data, "value"), do: 4, else: 3

    # need to restrict getting items to the people who own or have rights to access them!
    item = Item.get_item!(Map.get(data, "id"))
    Item.update_item(item, %{status: status, person_id: person_id})
    Timer.stop_timer_for_item_id(item.id)

    AppWeb.Endpoint.broadcast(@topic, "update", :toggle)
    {:noreply, socket}
  end
```

e.g.
[`lib/app_web/live/app_live.ex`](https://github.com/dwyl/mvp/blob/732f2518d792048a38449058a6d7efb088b3d26f/lib/app_web/live/app_live.ex#L66)

We are now passing the `person_id` when toggling 
(which is an updating operation) an item.

## 13.3 Fixing tests

If you run `mix test`,
you will notice we've broken quite a few of them!

```sh
..
Finished in 1.7 seconds (0.3s async, 1.3s sync)
78 tests, 26 failures

Randomized with seed 205107
```

Not to worry though, we can fix them!

The reason these tests are failing is because,
unlike operations like `Repo.insert` or `Repo.update`,
`PaperTrail.insert` and `PaperTrail.update` 
return a struct with two fields:
- the model changeset.
- `PaperTrail` version object,
which contains info about the changes made,
versioning, etc.

The returned struct looks like so:

```elixir
{:ok,
  %{
    model: %Item{__meta__: Ecto.Schema.Metadata<:loaded, "items"> ...},
    version: %PaperTrail.Version{__meta__: Ecto.Schema.Metadata<:loaded, "versions">...}  
  }
}
```

Many tests are creating `items` like:

```elixir
{:ok, item} = Item.create_item(@valid_attrs)
```

which should be changed to:

```elixir
{:ok, %{model: item, version: version}} = Item.create_item(@valid_attrs)
```

To fix the tests, all instances
of `Item.create_item`, 
`Item.create_item_with_tags`
and `Item.update_item`
should be changed according
to the example above.

Additionally, since we are using `id=0` 
as the default `person_id`,
inside `test/app/item_test.exs`,
update the `@update_attrs` to the following:

```elixir
@update_attrs %{text: "some updated text", person_id: 1}
```

This will make sure the isolated tests pass successfully.

You can see the updated files in:
- [test/app/item_test.exs](https://github.com/dwyl/mvp/blob/732f2518d792048a38449058a6d7efb088b3d26f/test/app/item_test.exs)
- [test/app/timer_test.exs](https://github.com/dwyl/mvp/blob/d80c2148b2d19535143d6d9794391f6fb3f2421f/test/app/timer_test.exs)
- [test/app_web/live/app_live_test.exs](https://github.com/dwyl/mvp/blob/d80c2148b2d19535143d6d9794391f6fb3f2421f/test/app_web/live/app_live_test.exs)

## 13.4 Checking the changes using `DBEaver`

If you run `mix phx.server` 
and create/update items,
you will see these events being tracked in the `Versions` table.

We often use `DBeaver`,
which is a PostgreSQL GUI. 
If you don't have this installed, 
[we highly recommend you doing so](https://github.com/dwyl/learn-postgresql/issues/43#issuecomment-469000357).

<img width="1824" alt="papertrail_versions" src="https://user-images.githubusercontent.com/17494745/211629270-996e6c4a-8322-49b4-9ef6-7be2335ccfb7.png">

As you can see, update/insert events are being tracked,
with the corresponding `person_id` (in `originator_id`),
the `item_id` that is being edited
and the corresponding changes.

# 14. Adding a dashboard to track metrics

Having a page to track metrics 
regarding app usage is important two-fold:
- if you are a **developer**, 
it's crucial to know if and how the app is being used,
to better implement features in the future.
- if you are a **`person` _using_ the `App`**, 
you want to view aggregate stats of how many 
`items` and `timers` you created
so you know how to improve your personal effectiveness.

Let's create a simple `/stats` dashboard
to display the number of `items` and `timers` each `person` has created
in a simple table.

Let's roll!


## 14.1 Adding new `LiveView` page in `/stats`


Open 
`lib/app_web/router.ex` 
and add the new route inside the `"/"` scope.

```elixir
    ...

    get "/login", AuthController, :login
    get "/logout", AuthController, :logout

    live "/stats", StatsLive
```

Now create the `StatsLive` file
with the path:
`lib/app_web/live/stats_live.ex`
and template at:
`lib/app_web/live/stats_live.html.heex`.

In `stats_live.ex`,
paste the following code:

```elixir
defmodule AppWeb.StatsLive do
  require Logger
  use AppWeb, :live_view
  alias App.Item
  alias Phoenix.Socket.Broadcast

  # run authentication on mount
  on_mount(AppWeb.AuthController)

  @stats_topic "stats"

  @impl true
  def mount(_params, _session, socket) do
    # subscribe to the channel
    if connected?(socket), do: AppWeb.Endpoint.subscribe(@stats_topic)

    metrics = Item.person_with_item_and_timer_count()

    {:ok,
     assign(socket,
       metrics: metrics
     )}
  end

  @impl true
  def handle_info(
        %Broadcast{topic: @stats_topic, event: "item", payload: payload},
        socket
      ) do
    metrics = socket.assigns.metrics

    case payload do
      {:create, payload: payload} ->
        updated_metrics =
          Enum.map(metrics, fn row -> add_row(row, payload, :num_items) end)

        {:noreply, assign(socket, metrics: updated_metrics)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        %Broadcast{topic: @stats_topic, event: "timer", payload: payload},
        socket
      ) do
    metrics = socket.assigns.metrics

    case payload do
      {:create, payload: payload} ->
        updated_metrics =
          Enum.map(metrics, fn row -> add_row(row, payload, :num_timers) end)

        {:noreply, assign(socket, metrics: updated_metrics)}

      _ ->
        {:noreply, socket}
    end
  end

  def add_row(row, payload, key) do
    row =
      if row.person_id == payload.person_id do
        Map.put(row, key, Map.get(row, key) + 1)
      else
        row
      end

    row
  end

  def person_link(person_id) do
    "https://auth.dwyl.com/people/#{person_id}"
  end
end
```

Let's break this down.
On `mount`, we are retrieving 
an array containing the number of items and timers of each person (`id` and `name`).
We are calling `Item.person_with_item_and_timer_count()` for this
(we will implement this right after this, don't worry!).

This `LiveView` is subscribed to a channel called `stats`,
and has two handlers which increment the number of `timers` or `items`
in real-time whenever a `person` joins.
For this to actually work, 
we need to broadcast to this channel. 

We will do this shortly!
But first, let's implement `Item.person_with_item_and_timer_count()`.


## 14.2 Fetching counter of `timers` and `items` for each `person`

In `lib/app/item.ex`,
add the following function:

```elixir
  def person_with_item_and_timer_count() do
    sql = """
    SELECT i.person_id,
    COUNT(distinct i.id) AS "num_items",
    COUNT(distinct t.id) AS "num_timers"
    FROM items i
    LEFT JOIN timers t ON t.item_id = i.id
    GROUP BY i.person_id
    ORDER BY i.person_id
    """

    Ecto.Adapters.SQL.query!(Repo, sql)
    |> map_columns_to_values()
  end
```

We are simply executing an SQL query expression
and retrieving it.
This function should yield a list of objects 
containing `person_id`, `name`, `num_items` and `num_timers`.

```elixir
[
  %{name: nil, num_items: 3, num_timers: 8, person_id: 0}
  %{name: username, num_items: 1, num_timers: 3, person_id: 1}
]
```


## 14.3 Building the Stats Page


We've created `lib/app_web/live/stats_live.html.heex`
but haven't implemented anything.
Let's fix that now.

Add this code to the file.

```html
<main class="font-sans container mx-auto">
  <div class="relative overflow-x-auto mt-12">
    <h1 class="mb-2 text-xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
      Stats
    </h1>
    <table class="text-sm text-left text-gray-500 dark:text-gray-400 table-auto">
      <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
        <tr>
          <th scope="col" class="px-6 py-3">
            Id
          </th>
          <th scope="col" class="px-6 py-3 text-center">
            Items
          </th>
          <th scope="col" class="px-6 py-3 text-center">
            Timers
          </th>
        </tr>
      </thead>
      <tbody>
        <%= for metric <- @metrics do %>
          <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
            <td class="px-6 py-4">
              <a href={person_link(metric.person_id)}>
                <%= metric.person_id %>
              </a>
            </td>
            <td class="px-6 py-4 text-center">
              <%= metric.num_items %>
            </td>
            <td class="px-6 py-4 text-center">
              <%= metric.num_timers %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>
</main>
```

We are simply creating a table with four columns,
one for `person_id`, person `name`, number of `items` and number of `timers`.
We are acessing the `@metrics` array 
that is fetched and assigned on `mount/3` inside `stats_live.ex`.

## 14.4 Broadcasting to `stats` channel


The only thing that is left to implement 
is broadcasting events from `lib/app_web/live/app_live.ex`
so `stats_live.ex` handles them and updates `stats_live.html.heex` accordingly.

In `lib/app_web/live/app_live.ex`,
let's create a new constant value 
for the `stats` channel.

```elixir
@topic "live"
@stats_topic "stats" # add this
```

Whenever an `item` or `timer` is created,
an event is going to be broadcasted to this channel.

Let's subscribe to the `stats` channel on mount,
similarly to what happens with `live`.
In `mount/3`,
subscribe to the `stats` channel
like we are doing to the `live` one.

```elixir
if connected?(socket), do:
  AppWeb.Endpoint.subscribe(@topic)
  AppWeb.Endpoint.subscribe(@stats_topic)
```

Now, in the 
`handle_event("create", %{"text" => text}, socket)` function,
broadcast an event to the `stats` channel
whenever an `item` is created.

```elixir
def handle_event("create", %{"text" => text}, socket) do
  person_id = get_person_id(socket.assigns)

  Item.create_item_with_tags(%{
    text: text,
    person_id: person_id,
    status: 2,
    tags: socket.assigns.selected_tags
  })

  AppWeb.Endpoint.broadcast(@topic, "update", :create)
  AppWeb.Endpoint.broadcast(@stats_topic, "item", {:create, payload: %{person_id: person_id}}) # add this
  {:noreply, assign(socket, text_value: "", selected_tags: [])}
end
```

Similarly, do the same for `timers`.

```elixir
def handle_event("start", data, socket) do
  item = Item.get_item!(Map.get(data, "id"))
  person_id = get_person_id(socket.assigns)

  {:ok, _timer} =
    Timer.start(%{
      item_id: item.id,
      person_id: person_id,
      start: NaiveDateTime.utc_now()
    })

  AppWeb.Endpoint.broadcast(@topic, "update", {:start, item.id})
  AppWeb.Endpoint.broadcast(@stats_topic, "timer", {:create, payload: %{person_id: person_id}}) # add this
  {:noreply, socket}
end
```

In the same file,
`app_live.ex` 
also needs to have a handler
of these new event broadcasts,
or else an error is thrown.

```sh
no function clause matching in AppWeb.AppLive.handle_info/2
```

`app_live.ex` doesn't really care about these events,
so we do nothing with them.
Add the following function for this.

```elixir
@impl true
def handle_info(%Broadcast{topic: @stats_topic, event: _event, payload: _payload}, socket) do
  {:noreply, socket}
end

```


## 14.5 Adding tests

Let's add the tests to cover the use case
we just created.

Firstly, let's create a file:
`test/app_web/live/stats_live_test.exs`
and add the following code to it:

```elixir
defmodule AppWeb.StatsLiveTest do
  use AppWeb.ConnCase, async: true
  alias App.{Item, Timer}
  import Phoenix.LiveViewTest

  @person_id 55

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/stats")
    assert disconnected_html =~ "Stats"
    assert render(page_live) =~ "Stats"
  end

  test "display metrics on mount", %{conn: conn} do
    # Creating two items
    {:ok, %{model: item, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, %{model: _item2, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 4, person_id: @person_id})

    assert item.status == 2

    # Creating one timer
    started = NaiveDateTime.utc_now()
    {:ok, _timer} = Timer.start(%{item_id: item.id, start: started})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # two items and one timer expected
    assert render(page_live) =~
             "<td class=\"px-6 py-4 text-center\">\n2\n            </td><td class=\"px-6 py-4 text-center\">\n1\n            </td>"
  end

  test "handle broadcast when item is created", %{conn: conn} do
    # Creating an item
    {:ok, %{model: _item, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # num of items
    assert render(page_live) =~
             "<td class=\"px-6 py-4 text-center\">\n1\n            </td><td class=\"px-6 py-4 text-center\">\n0\n            </td>"

    # Creating another item.
    AppWeb.Endpoint.broadcast(
      "stats",
      "item",
      {:create, payload: %{person_id: @person_id}}
    )

    # num of items
    assert render(page_live) =~
             "<td class=\"px-6 py-4 text-center\">\n2\n            </td><td class=\"px-6 py-4 text-center\">\n0\n            </td>"

    # Broadcasting update. Shouldn't effect anything in the page
    AppWeb.Endpoint.broadcast(
      "stats",
      "item",
      {:update, payload: %{person_id: @person_id}}
    )

    # num of items
    assert render(page_live) =~
             "<td class=\"px-6 py-4 text-center\">\n2\n            </td><td class=\"px-6 py-4 text-center\">\n0\n            </td>"
  end

  test "handle broadcast when timer is created", %{conn: conn} do
    # Creating an item
    {:ok, %{model: _item, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", status: 2, person_id: @person_id})

    {:ok, page_live, _html} = live(conn, "/stats")

    assert render(page_live) =~ "Stats"
    # num of timers
    assert render(page_live) =~
             "<td class=\"px-6 py-4 text-center\">\n1\n            </td><td class=\"px-6 py-4 text-center\">\n0\n            </td>"

    # Creating a timer.
    AppWeb.Endpoint.broadcast(
      "stats",
      "timer",
      {:create, payload: %{person_id: @person_id}}
    )

    # num of timers
    assert render(page_live) =~
             "<td class=\"px-6 py-4 text-center\">\n1\n            </td><td class=\"px-6 py-4 text-center\">\n1\n            </td>"

    # Broadcasting update. Shouldn't effect anything in the page
    AppWeb.Endpoint.broadcast(
      "stats",
      "timer",
      {:update, payload: %{person_id: @person_id}}
    )

    # num of timers
    assert render(page_live) =~
             "<td class=\"px-6 py-4 text-center\">\n1\n            </td><td class=\"px-6 py-4 text-center\">\n1\n            </td>"
  end

  test "add_row/3 adds 1 to row.num_timers" do
    row = %{person_id: 1, num_items: 1, num_timers: 1}
    payload = %{person_id: 1}

    # expect row.num_timers to be incremented by 1:
    row_updated = AppWeb.StatsLive.add_row(row, payload, :num_timers)
    assert row_updated == %{person_id: 1, num_items: 1, num_timers: 2}

    # no change expected:
    row2 = %{person_id: 2, num_items: 1, num_timers: 42}
    assert row2 == AppWeb.StatsLive.add_row(row2, payload, :num_timers)
  end
end
```

We've now covered the `stats_live.ex` file thoroughly.
The *last* thing we need to do
is to add a test for the `person_with_item_and_timer_count/0`
function that was implemented inside `lib/app/item.ex`.

Open `test/app/item_test.exs`
and add this test:

```elixir
  test "Item.person_with_item_and_timer_count/0 returns a list of count of timers and items for each given person" do
    {:ok, item1} = Item.create_item(@valid_attrs)
    {:ok, item2} = Item.create_item(@valid_attrs)

    started = NaiveDateTime.utc_now()

    {:ok, timer1} =
      Timer.start(%{
        item_id: item1.id,
        person_id: item1.person_id,
        start: started,
        stop: started
      })

    {:ok, _timer2} =
      Timer.start(%{item_id: item2.id, person_id: item2.person_id, start: started})

    # list person with number of timers and items
    person_with_items_timers = Item.person_with_item_and_timer_count()

    assert length(person_with_items_timers) == 1

    first_element = Enum.at(person_with_items_timers, 0)

    assert Map.get(first_element, :num_items) == 2
    assert Map.get(first_element, :num_timers) == 2
  end
```


And you're done!
Awesome job! 🎉
If you run `mix phx.server`,
you should see `/stats` being updated **live** 
when creating `timers` or `items`.

![stats_final](https://user-images.githubusercontent.com/17494745/211345854-c541d21c-4289-4576-8fcf-c3b89251ed02.gif)


# 15. `People` in Different Timezones 🌐

Our application works not only for ourselves
but in a *collaborative environment*. 
Not everyone lives within the same timezone.
We might have a person living in South Korea (`UTC+9`)
and others living in the US `UTC-5`
if they each start a timer at the _same_ time
and we don't record the timezone info
there will be a mismatch in the elapsed time ...


For a good visual understanding of the different timezones
see:
[everytimezone.com](https://everytimezone.com)
<img width="1028" alt="every timezone" src="https://github.com/dwyl/mvp/assets/194400/d2b95a14-24ea-4a1c-ac1c-520d7fc07d21">

You can see that `09:00` in `London`
is `04:00` in `NYC` 
and `20:00` in `Auckland`. 

This is fine when all the `people` collaborating together 
are working on the **_same_ day**.

Consider the `person` 
starting a `timer` at `09:00` 
on the `Friday` Morning in `Auckland`:

<img width="819" alt="image" src="https://github.com/dwyl/mvp/assets/194400/bd8ae024-0b9a-420e-a84e-4f6a2c4b7d08">

For their colleague in `LA` (`UTC-7`) it's still 
`14:00` on the _`Thursday`_ i.e. the **_previous_ day**!
This can rapidly get confusing for people collaborating around the world.


The point is:
**we clearly need to deal with `people` living in different timezones**.
As it stands, the server-side of the `MVP` 
saves every `timer` according to the 
[`UTC` timezone](https://en.wikipedia.org/wiki/Coordinated_Universal_Time)
and this is shown to the `person` as well.
This, of course, only makes sense to people living
within this timezone.
If you were to live on another one,
the value of the `Datetime` of the `timer`
*wouldn't make sense to you*.


## 15.1 Getting the `person`'s Timezone

The easiest way to solve this is
to only change how the `timers` are displayed
**according to the timezone of the client**.

**The datetime will still be saved as `UTC` within the database**.
This makes it much easier not only to maintain consistency
across collaborative environments 
but to also better trail activity.

Since we are going to be adjusting the dates shown
on the client-side only,
we need a way for the server to know the timezone as well,
so we can adjust the updated timer values *back to UTC* 
before persisting into the database.

We can leverage 
[`get_connect_params/1`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#get_connect_params/1)
to pass information from the client
to the `LiveView` server during the mounting phase.

Open `assets/js/app.js`
and locate the 
`let liveSocket = new LiveSocket()` variable.
We are going to be changing the `params` attribute.
Change it to the following:

```js
params: {
  _csrf_token: csrfToken,
  hours_offset_fromUTC: -new Date().getTimezoneOffset()/60
}
```

We are passing a parameter called `hours_offset_fromUTC`
that represents the amount of hours the client
is from the `UTC`.
By multiplying this value by `-1`, 
we are calculating _our_ timezone's offset **from** `UTC`.
For more information,
read: 
[stackoverflow.com/questions/13/determine-a-users-timezone/1809974](https://stackoverflow.com/questions/13/determine-a-users-timezone/1809974#1809974.)

To use this within LiveView,
we are going to be assigning this value to the socket.
For this, open `lib/app_web/live/app_live.ex`
and locate the `mount/3` function at the top of the file.
We are going to be adding this new value to the socket assigns,
like so:

```elixir
  {:ok,
    assign(socket,
      items: items,
      editing_timers: [],
      editing: nil,
      filter: "active",
      filter_tag: nil,
      tags: tags,
      selected_tags: selected_tags,
      text_value: draft_item.text || "",

      # Offset from the client to UTC. If it's "1", it means we are one hour ahead of UTC.
      hours_offset_fromUTC: get_connect_params(socket)["hours_offset_fromUTC"] || 0
  )}
```

If `hours_offset_fromUTC` is not defined, 
we assume the user is in the UTC timezone
(it has a value of 0).

Awesome! 🎉

Now we can use this value to adjust the timezone 
to adjust the timezone every time we update a timer!
But before that, 
let's adjust how it is *displayed to the person*.


## 15.2 Changing how the timer datetime is displayed

Open `lib/app_web/live/app_live.html.heex`
and locate the line
`<%= @editing_timers |> Enum.with_index |> Enum.map(fn({changeset, index}) -> %>`.
We are going to be changing the **Start** and **Stop** value
of the `timer`.

Inside this loop,
locate the `<input>` tags 
pertaining to the `timer_start`
and `timer_stop` and change them.

For `timer_start`, change it to:

```html
<input
  type="text"
  required="required"
  name="timer_start"
  id={"#{changeset.data.id}_start"}
  value={NaiveDateTime.add(changeset.data.start, @hours_offset_fromUTC, :hour)}
/>
```

And for `timer_stop`, make these changes:

```html
<input
  type="text"
  name="timer_stop"
  id={"#{changeset.data.id}_stop"}
  value={if is_nil(changeset.data.stop) do changeset.data.stop else NaiveDateTime.add(changeset.data.stop, @hours_offset_fromUTC, :hour) end}
/>
```

We are changing the number of hours displayed
according to the `@hours_offset_fromUTC` socket assigns
we've declared previously.
In the `timer_stop` case,
we are checking if the value is `nil`
(ongoing timers have the `stop` field as `nil`)
so they are displayed properly.

To see the changes needed,
please check 
[`lib/app_web/live/app_live.html.heex`](https://github.com/dwyl/mvp/blob/63d98958be8f858e6ebcd063fa022bb59964b612/lib/app_web/live/app_live.html.heex#L326-L341).


## 15.3 Persisting the adjusted timezone

Now that we are displaying the correct timezones,
we need to make sure the adjusted updated timer
is **converted *back* to UTC before persisting into the database**.

For this, 
we simply need to do this operation
inside the `update_timer_inside_changeset_list/3` function
inside `lib/app/timer.ex`.

This function will now receive the adjusted timezone 
and change the updated timer value(s) *back* to UTC.
Now the function will receive a new parameter
with the `hours_offset_fromUTC`.

Locate the two pattern match functions called `update_timer_inside_changeset_list`
and add a new parameter:

```elixir
def update_timer_inside_changeset_list(
    %{
      id: timer_id,
      start: timer_start,
      stop: timer_stop
    },
    index,
    timer_changeset_list,
    hours_offset_fromUTC      # add this line
  )
  ...
```

In the first function 
(with the guard `when timer_stop == "" or timer_stop == nil`),
add the following line.

```elixir
 def update_timer_inside_changeset_list(
        %{
          id: timer_id,
          start: timer_start,
          stop: timer_stop
        },
        index,
        timer_changeset_list,
        hours_offset_fromUTC
      )
      when timer_stop == "" or timer_stop == nil do

    changeset_obj = Enum.at(timer_changeset_list, index)
    try do

      {start_op, start} =
        Timex.parse(timer_start, "%Y-%m-%dT%H:%M:%S", :strftime)

      if start_op === :error do
        throw(:error_invalid_start)
      end

      # Add this new line
      start = NaiveDateTime.add(start, -hours_offset_fromUTC, :hour)

      other_timers_list = List.delete_at(timer_changeset_list, index)
```

On the other pattern-matched function,
add the following lines.

```elixir
  def update_timer_inside_changeset_list(
        %{
          id: timer_id,
          start: timer_start,
          stop: timer_stop
        },
        index,
        timer_changeset_list,
        hours_offset_fromUTC
      ) do

    changeset_obj = Enum.at(timer_changeset_list, index)
    try do

      {start_op, start} =
        Timex.parse(timer_start, "%Y-%m-%dT%H:%M:%S", :strftime)
      {stop_op, stop} = Timex.parse(timer_stop, "%Y-%m-%dT%H:%M:%S", :strftime)

      if start_op === :error do
        throw(:error_invalid_start)
      end
      if stop_op === :error do
        throw(:error_invalid_stop)
      end

      # Add these two lines
      start = NaiveDateTime.add(start, -hours_offset_fromUTC, :hour)
      stop = NaiveDateTime.add(stop, -hours_offset_fromUTC, :hour)
```

If you want to see the changes you need to make,
please check 
[`lib/app/timer.ex`](https://github.com/dwyl/mvp/blob/63d98958be8f858e6ebcd063fa022bb59964b612/lib/app/timer.ex#L153-L260).

The last thing we need to do is 
pass this new parameter inside 
`lib/app_web/live/app_live.ex`
that *calls* this function.

Locate 
```elixir
def handle_event("update-item-timer"
```

and pass the `hours_offset_fromUTC` assign from the socket
to the `update_timer_inside_changeset_list/4`.

```elixir
case Timer.update_timer_inside_changeset_list(
        timer,
        index,
        timer_changeset_list,
        socket.assigns.hours_offset_fromUTC    # add this new line
) do
```

If you're curious to see the change you ought to make,
please check
[`lib/app_web/live/app_live.ex`](https://github.com/dwyl/mvp/blob/63d98958be8f858e6ebcd063fa022bb59964b612/lib/app_web/live/app_live.ex#L218).


## 15.4 Adding test

Let's add a test case that will check if the datetime 
is shown with an offset that is mocked during testing.
We expect the datetime to show a different datetime
than the `Timer` object that is persisted in the database.

Let's test it.
Open `test/app_web/live/app_live_test.exs`
and add the following unit test.

```elixir
  test "item\'s timer shows correct value (adjusted timezone)", %{conn: conn} do
    {:ok, %{model: item, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, seven_seconds_ago} =
      NaiveDateTime.new(Date.utc_today(), Time.add(Time.utc_now(), -7))

    # Start the timer 7 seconds ago:
    {:ok, timer} =
      Timer.start(%{item_id: item.id, person_id: 1, start: seven_seconds_ago})

    # Stop the timer based on its item_id
    Timer.stop_timer_for_item_id(item.id)

    # Adding timezone socket assign to simulate we're one hour ahead of UTC
    hours_offset_fromUTC = 1

    conn =
      put_connect_params(conn, %{"hours_offset_fromUTC" => hours_offset_fromUTC})

    {:ok, view, _html} = live(conn, "/")

    edit_timer_view =
      render_click(view, "edit-item", %{"id" => Integer.to_string(item.id)})

    # `Start` and `stop` of the timer in the database (in UTC)
    # We expect the `start` and `stop` to be shown with one hour more in the view
    timer = Timer.get_timer!(timer.id)

    expected_start_in_view =
      NaiveDateTime.add(timer.start, hours_offset_fromUTC, :hour)
      |> NaiveDateTime.to_iso8601()

    expected_stop_in_view =
      NaiveDateTime.add(timer.stop, hours_offset_fromUTC, :hour)
      |> NaiveDateTime.to_iso8601()

    # Check if timers are being shown correctly.
    # They should be adjusted to timezone.
    assert edit_timer_view =~ expected_start_in_view
    assert edit_timer_view =~ expected_stop_in_view

    # Now let's update the timer with a new value.
    # This is the value the user inputs in the client-side.
    # Since the user is in UTC+1, the persisted value should be adjusted
    start = "2022-10-27T01:00:00"
    stop = "2022-10-27T01:30:00"
    {:ok, persisted_start} = NaiveDateTime.from_iso8601("2022-10-27T00:00:00")
    {:ok, persisted_stop} = NaiveDateTime.from_iso8601("2022-10-27T00:30:00")

    render_submit(view, "update-item-timer", %{
             "timer_id" => timer.id,
             "index" => 0,
             "timer_start" => start,
             "timer_stop" => stop
           })

    updated_timer = Timer.get_timer!(timer.id)

    # The persisted datetime in the database should be one hour less
    # than what the user has input.
    assert NaiveDateTime.compare(updated_timer.start, persisted_start) == :eq
    assert NaiveDateTime.compare(updated_timer.stop, persisted_stop) == :eq
  end
```

As you can see,
since we are using `get_connect_params` when mounting
in the LiveView to get the timezone,
we are using 
[`put_connect_params`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html#put_connect_params/2)
in our unit test to mock this value.

We are passing with a value of `1`.
With this, we expect the timer values
in the view to be shown 
the timer value with one hour incremented.

We are also checking the value of the persisted timer
within the database.
Given the timer value is adjusted *back* 
according to the person's timezone,
we expect the persisted value to be
one hour *less* than what the person inputted. 


# 16. `Lists`

In preparation for the next set of features in the `MVP`,
we are going to add `lists`
which are simply a collection of `items`.

Please see: 
[book/mvp/lists](https://dwyl.github.io/book/mvp/15-lists.html)


# 17. Reordering `items` Using Drag & Drop

At present `people` using the `App`
can only add new `items` to a stack
where the newest is on top; no ordering.

`people` that tested the `MVP`
noted that the ability to **reorder `items`**
was an **_essential_ feature**:
[dwyl/mvp**#145**](https://github.com/dwyl/mvp/issues/145)

So in this step we are going to 
add the ability to organize `items`.
We will implement reordering using 
**drag and drop**!
And by using `Phoenix Liveview`,
**other people** will also be able 
to **see the changes in real time**!




##  17.1 `Item` schema changes

By introducing this feature 
(and so everyone sees the correct positioning of each item),
we ought to add a new field:
**`position`**.
This new field called **`position`** will be an `integer`,
referencing the *index of the item within the list*.

The `position` field can't be under `0` 
and will dynamically change according to the position of the item in the list.

With this in mind,
let's add this field in our migration 
and schema definition files.

Open `priv/repo/migrations/20220627162154_create_items.exs`
and add the following line.

```elixir
  add(:text, :string)
  add(:person_id, :integer)
  add(:status, :integer)
  add(:position, :integer)   # add this line

  timestamps()
end
```

In `lib/app/item.ex`,
add the field as well.
We are also going to change the `changeset` functions
to accept this field.

```elixir
  schema "items" do
    field :person_id, :integer
    field :status, :integer
    field :text, :string
    field :position, :integer    # add this line

    has_many :timer, Timer
    many_to_many(:tags, Tag, join_through: ItemTag, on_replace: :delete)

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:person_id, :status, :text, :position])   # add the `:position` field
    |> validate_required([:text, :person_id])
  end

  def changeset_with_tags(item, attrs) do
    changeset(item, attrs)
    |> put_assoc(:tags, attrs.tags)
  end

  def draft_changeset(item, attrs) do
    item
    |> cast(attrs, [:person_id, :status, :text, :position])   # add the `:position` field
    |> validate_required([:person_id])
  end
```

To reset the database changes,
we run `mix ecto.reset`
and then `mix ecto.setup` 
to rebuild our database with our added `position` column.


## 16.2 Changing the Item's `position` field in the database

We now need to have a few functions
that will *change* the `position` field value of the item.

Whenever a new todo item is added,
it should be added to the top of the list
(as it currently is).
For this to work with the `position` field,
we need to **increment the positions of each item of the list whenever a new item is added**.
For this, in `lib/app/item.ex`
create the following function.

```elixir
  defp reorder_list_to_add_item(%Item{position: position}) do
    # Increments the positions above a given position.
    # We are making space for the item to be added.

    from(i in Item,
      where: i.position > ^position,
      update: [inc: [position: 1]]
    )
    |> Repo.update_all([])
  end
```

This function uses [`update_all/3`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:update_all/3)
to increment all the item's positions
above a given `position` value.

When a user drag and drops an item in a new index,
we are *basically switching the `position` value of the two items*.
Let's create a function for this.
This function will receive the item `id` of the **origin item**
and the **target item** 
and perform a basic switch,
saving the new `positions` in the database.


```elixir
  def move_item(id_from, id_to) do
    item_from = get_item!(id_from)
    itemPosition_from = Map.get(item_from, :position)

    item_to = get_item!(id_to)
    itemPosition_to = Map.get(item_to, :position)

    {:ok, %{model: _item, version: _version}} =
      update_item(item_from, %{position: itemPosition_to})

    {:ok, %{model: _item, version: _version}} =
      update_item(item_to, %{position: itemPosition_from})
  end
```

With these new two functions,
we ought to change the functions
that **create an item**
so they create an `item` on the top of the list.

In the same file,
change the two following functions
so they look like so.

```elixir
  def create_item(attrs) do
    ## Make room at beginning of list first.
    reorder_list_to_add_item(%Item{position: -1})

    %Item{position: 0}
    |> changeset(attrs)
    |> PaperTrail.insert(originator: %{id: Map.get(attrs, :person_id, 0)})
  end

  def create_item_with_tags(attrs) do
    # Make room at beginning of list first.
    # This increments the positions of the items.
    reorder_list_to_add_item(%Item{position: -1})

    %Item{position: 0}
    |> changeset_with_tags(attrs)
    |> PaperTrail.insert(originator: %{id: Map.get(attrs, :person_id, 0)})
  end
```

We've used the `reorder_list_to_add_item/1` function
we've created to "make room" for the new item 
that is being created.

## 16.3 Return `position` in `items_with_timers` function

Since we are calling the `items_with_timers/1` function
(located in `lib/app/item.ex`)
on startup to fetch the item list,
we need to change it so it *also returns the `position` field*.

Therefore,
change it so it looks like the following
snippet of code.

```elixir
  def items_with_timers(person_id \\ 0) do
    sql = """
    SELECT i.id, i.text, i.status, i.person_id, i.position, t.start, t.stop, t.id as timer_id FROM items i
    FULL JOIN timers as t ON t.item_id = i.id
    WHERE i.person_id = $1 AND i.status IS NOT NULL
    ORDER BY i.position ASC;
    """

    values =
      Ecto.Adapters.SQL.query!(Repo, sql, [person_id])
      |> map_columns_to_values()

    items_tags =
      list_person_items(person_id)
      |> Enum.reduce(%{}, fn i, acc -> Map.put(acc, i.id, i) end)

    accumulate_item_timers(values)
    |> Enum.map(fn t ->
      Map.put(t, :tags, items_tags[t.id].tags)
    end)
    |> Enum.sort_by(& &1.position)
  end
```

And that's it!
We are now returning the `position` of the item
and also *ordering* the list
by ascending `position`.


## 16.4 Implementing drag and drop in `Liveview`

To add `drag and drop` to the Liveview app,
we have created a separate guide.

Since our project already uses `Alpine.js`,
you may follow
https://github.com/dwyl/learn-alpine.js/blob/main/drag-and-drop.md
to implement drag and drop in the app.

There are a few differences in our project
compared with the guide in the link above.

- we've used https://heroicons.dev/?search=dots
to add an icon to the todo item in `lib/app_web/live/app_live.html.heex`.
- in `assets/js/app.js`,
we create an `update-indexes` event by passing
the **origin item `id`** to switch with the **target item `id`**.
We use a global variable called `itemId_to`
that is updated whenever it is dragged over an item on the list.
*The last value of `itemId_to` is the target item `id`*.

If you want to see the changes we've made,
you can check the pull request - 
https://github.com/dwyl/mvp/pull/345/files#.


## 16.5 Adding unit test

To get our coverage back to 100%,
we ougth to add a simple test that will simulate
the dragover and update events,
as well as the highlights that are seen by each person
connected to the Liveview.

In `test/app_web/live/app_live_test.exs`,
simply add the following test.

```elixir
  test "drag and drop item", %{conn: conn} do
    # Creating two items
    {:ok, %{model: item, version: _version}} =
      Item.create_item(%{text: "Learn Elixir", person_id: 0, status: 2})

    {:ok, %{model: item2, version: _version}} =
      Item.create_item(%{text: "Learn Elixir 2", person_id: 0, status: 2})

    pre_item_position = item.position
    pre_item2_position = item2.position

    # Render liveview
    {:ok, view, _html} = live(conn, "/")

    # Highlight broadcast should have occurred
    assert render_hook(view, "highlight", %{"id" => item.id})
           |> String.split("bg-yellow-300")
           |> Enum.drop(1)
           |> length() > 0

    # Dragover and remove highlight
    render_hook(view, "dragoverItem", %{
      "currentItemId" => item2.id,
      "selectedItemId" => item.id
    })

    assert render_hook(view, "removeHighlight", %{"id" => item.id})

    # Switch items (update indexes)
    render_hook(view, "updateIndexes", %{
      "itemId_from" => item.id,
      "itemId_to" => item2.id
    })

    assert item.position == pre_item2_position
    assert item2.position == pre_item_position
  end
```

## 16.6 Check it in action!

If you run `mix phx.server`,
you can now drag and drop each item.
When dragging, the item **will be highlighted**
and this highlight **is visible to all people in the same Liveview**.

![dragndrop_final](https://user-images.githubusercontent.com/17494745/229785696-e109ac59-ee87-4d66-b580-ce0ca25d5f40.gif)


# 17. Run the _Finished_ MVP App!

With all the code saved, let's run the tests one more time.

## 17.1 Run the Tests

In your terminal window, run: 

```sh
mix c
```

> Note: this alias was defined [above](#test-coverage)

You should see output similar to the following:

```sh
Finished in 1.5 seconds (1.4s async, 0.1s sync)
117 tests, 0 failures

Randomized with seed 947856
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/api/item.ex                               218       56        0
100.0% lib/api/tag.ex                                101       24        0
100.0% lib/api/timer.ex                              152       40        0
100.0% lib/app/color.ex                               90        1        0
100.0% lib/app/item.ex                               415       62        0
100.0% lib/app/item_tag.ex                            12        1        0
100.0% lib/app/tag.ex                                108       18        0
100.0% lib/app/timer.ex                              452       84        0
100.0% lib/app_web/controllers/auth_controller.       26        4        0
100.0% lib/app_web/controllers/init_controller.       41        6        0
100.0% lib/app_web/controllers/tag_controller.e       77       25        0
100.0% lib/app_web/live/app_live.ex                  476      132        0
100.0% lib/app_web/live/stats_live.ex                 77       21        0
100.0% lib/app_web/router.ex                          49        9        0
100.0% lib/app_web/views/error_view.ex                59       12        0
  0.0% lib/app_web/views/profile_view.ex               3        0        0
  0.0% lib/app_web/views/tag_view.ex                   3        0        0
[TOTAL] 100.0%
----------------
```

All tests pass and we have **`100%` Test Coverage**.
This reminds us just how few _relevant_ lines of code there are in the MVP!

## 17.2 Run The App

In your second terminal tab/window, run:

```sh
mix phx.server
```

Open the app 
[`localhost:4000`](http://localhost:4000) 
in two or more web browsers
(so that you can see the realtime sync)
and perform the actions
listed in the `README.md`.

e.g: 

![mvp-localhost-demo](https://user-images.githubusercontent.com/194400/183337496-429af597-45a2-447f-9061-a494907736d9.gif)



<br />

# Thanks!

Thanks for reading this far.
If you found it interesting,
please let us know by starring the repo on GitHub! ⭐


<br />

[![HitCount](https://hits.dwyl.com/dwyl/app-mvp-build.svg)](https://hits.dwyl.com/dwyl/app-mvp)
