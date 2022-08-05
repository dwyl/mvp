# Build Log 👩‍💻

This is a log 
of the steps taken 
to build the MVP. <br />
It took us _hours_ 
to write it,
but you can ***speed-run*** it 
in **20 minutes**. 🏁

> **Note**: we have referenced sections 
> in our more extensive tutorials/examples
> to keep this doc brief
> and avoid duplication.
> You don't have to follow every step in
> the other tutorials/examples,
> but they are linked in case you get stuck.

## 1. Create a New `Phoenix` App

Open your terminal and 
**create** a **new `Phoenix` app**
with the following command:

```sh
mix phx.new app --no-mailer --no-dashboard --no-gettext
```

When asked to install the dependencies,
type `Y` and `[Enter]` (_to install everything_).

The MVP won't be 
send emails,
display dashboards 
or translate to other languages
(sorry).
However _all_ of those things 
will be in the _main_ 
[dwyl/**app**](https://github.com/dwyl/app)
we're just excluding them here
to reduce complexity/dependencies.

### 1.1 Run the `Phoenix` App

Run the `Phoenix` app with the command:

```sh
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


### 1.2 Run the tests:

To run the tests with 


You should see output similar to:

```sh
...

Finished in 0.1 seconds (0.07s async, 0.07s sync)
3 tests, 0 failures
```

That tells us everything is working as expected. 🚀


#### Test Coverage?

If you prefer to see **test coverage** - we certainly do -
then you will need to add a few lines to the 
[`mix.exs`](https://github.com/dwyl/app-mvp/blob/main/mix.exs)
file and
create a 
[`coveralls.json`](https://github.com/dwyl/app-mvp/blob/main/coveralls.json)
file to exclude `Phoenix` files from `excoveralls` checking.
Add alias (shortcuts) in `mix.exs` `defp aliases do` list.
e.g: `mix c` runs `mix coveralls.html` 
see: [**`commits/d6ab5ef`**](https://github.com/dwyl/app-mvp/pull/90/commits/d6ab5ef7c2be5dcad7d060e782393ae29c94a526) ...

This is just standard `Phoenix` project setup for us, 
so we don't duplicate any of the steps here.
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


### 1.3 Setup `Tailwind`

As we're using **`Tailwind CSS`**
for the **UI** in this project
we need to enable it.

We are not duplicating the instructions here,
please refer to:
[Tailwind in Phoenix](https://github.com/dwyl/learn-tailwind#part-2-tailwind-in-phoenix).
Should only take **`~1 minute`**.

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

### 1.4 Setup `LiveView`

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

### 1.5 Update `router.ex`

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

![liveveiw-page-with-tailwind-style](https://user-images.githubusercontent.com/194400/176137805-34467c88-add2-487f-9593-931d0314df62.png)

### 1.6 Update Tests

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

Save the file 
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

### 1.7 Delete Page-related Files

Since we won't be using the `page` meatphore in our App, 
we can delete the default files created by `Phoenix`:

```sh
lib/app_web/views/page_view.ex
lib/app_web/controllers/page_controller.ex
lib/app_web/templates/page/index.html.heex
test/app_web/controllers/page_controller_test.exs
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

## 2. Create Schemas to Store Data

Create database schemas 
to store the data.
Run the following 
[**`mix phx.gen.schema`**](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html)
commands:

```sh
mix phx.gen.schema Item items text:string person_id:integer status:integer
mix phx.gen.schema Timer timers item_id:references:items start:naive_datetime stop:naive_datetime
```

At the end of this step,
we have the following database
[Entity Relationship Diagram](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model)
(ERD):

![mvp-erd-items-timers](https://user-images.githubusercontent.com/194400/180363191-79c0621b-04a1-4b0e-81e1-51345cc2e86d.png)


We created **2 database tables**;
`items`  and `timers`.
Let's run through them.

### _Explanation_ of the Schemas

This is a quick breakdown of the schemas created above:

#### `item`

An `item` is the most basic unit of content.
An **`item`** is just a **`String`** of **`text`**.
Later we will be able to 
e.g: a "note", "task", "reminder", etc.
The name **`item`** is **_deliberately_ generic**
as it maintains complete flexibility 
for what we are building later on.

+ `id`: `Int` - the auto-incrementing `id`.
+ `inserted_at`: `NaiveDateTime` - created/managed by `Phoenix`
+ `updated_at`: `NaiveDateTime`
+ `text`: `Binary` (_encrypted_) - the free text you want to capture.
+ `person_id`: `Integer` 
   the "owner" of the `item`)
+ `status`: `Integer`  the `status` of the `item` 
  e.g: "in progress"

#### `timer`

A `timer` is attached to an `item`
to track how long it takes to ***complete***.

  + `id`: `Int`
  + `inserted_at`: `NaiveDateTime`
  + `updated_at`: `NaiveDateTime`
  + `item_id` (Foreign Key `item.id`)
  + `start`: `NaiveDateTime` - time started on device
  + `stop`: `NaiveDateTime` - time ended on device

An `item` can have zero or more `timers`.
Each time a `item` (`task`) is worked on
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

### 2.1 Run Tests!

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
`lib/app/item.ex`, 
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

## 3. Input Items!

Create the directory `test/app`
and file:
`test/app/item_test.exs`
with the following code:

```elixir
defmodule App.ItemTest do
  use App.DataCase
  alias App.Item

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
      items = Item.list_items()
      assert Enum.count(items) == 2
    end

    test "update_item/2 with valid data updates the item" do
      {:ok, item} = Item.create_item(@valid_attrs)

      assert {:ok, %Item{} = item} = Item.update_item(item, @update_attrs)
      assert item.text == "some updated text"
    end
  end
end
```



### 3.1 Hard-code `item.person_id`






## 4. Add Authentication



