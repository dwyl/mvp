<div align="center">

# @dwyl App MVP `Phoenix`  💡⏳ ✅

A `Phoenix` implementation
of the @dwyl App 
[MVP feature set](https://github.com/dwyl/app/issues/266).

[![Build Status](https://img.shields.io/travis/com/dwyl/app-mvp-phoenix/master?color=bright-green&style=flat-square)](https://travis-ci.org/dwyl/app-mvp-phoenix)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/app-mvp-phoenix/master.svg?style=flat-square)](https://codecov.io/github/dwyl/app-mvp-phoenix?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/elixir_auth_google?color=brightgreen&style=flat-square)](https://hex.pm/packages/elixir_auth_google)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/app-mvp-phoenix/issues)
[![HitCount](https://hits.dwyl.com/dwyl/app-mvp-phoenix.svg)](https://hits.dwyl.com/dwyl/app-mvp-phoenix)


  <a href="https://agilevelocity.com/product-owner/mvp-mmf-psi-wtf-part-one-understanding-the-mvp">
    <img src="https://user-images.githubusercontent.com/194400/65666966-b28dbd00-e036-11e9-9d11-1f5d3e22258e.png" width="500" alt="MVP Loop">
  </a>
</div>


- [@dwyl App MVP `Phoenix`  💡⏳ ✅](#dwyl-app-mvp-phoenix---)
- [Why? 🤷](#why-)
- [_What_? 💭](#what-)
  - [3 Apps into _One_](#3-apps-into-one)
  - [Tech Stack?](#tech-stack)
- [_Who?_ 👥](#who-)
  - [Feedback! 🙏](#feedback-)
- [_How_? 💻](#how-)
  - [Run the MVP App on your `localhost` ⬇️](#run-the-mvp-app-on-your-localhost-️)
  - [_Single_ Environment Variable: `AUTH_API_KEY`](#single-environment-variable-auth_api_key)
- [Build Log 👩‍💻](#build-log-)
  - [0. Prerequisites](#0-prerequisites)
  - [1. Create a New `Phoenix` App](#1-create-a-new-phoenix-app)
    - [1.1 Run the `Phoenix` App](#11-run-the-phoenix-app)
    - [1.2 Run the tests:](#12-run-the-tests)
    - [1.3 Setup `Tailwind`](#13-setup-tailwind)
    - [1.4 Setup `LiveView`](#14-setup-liveview)
    - [1.5 Update `router.ex`](#15-update-routerex)
    - [1.6 Update Tests](#16-update-tests)
    - [1.7 Delete Page-related Files](#17-delete-page-related-files)
  - [2. Create Schemas to Store Data](#2-create-schemas-to-store-data)
    - [_Explanation_ of the Schemas](#explanation-of-the-schemas)
      - [`person`](#person)
      - [`item`](#item)
      - [`status`](#status)
      - [Schema Notes](#schema-notes)
    - [2.1 Create `item_tags` Association](#21-create-item_tags-association)
      - [`item_tags`](#item_tags)
    - [2.2 Run Tests!](#22-run-tests)
  - [_Create_ Schemas](#create-schemas)
    - [Associate Items with a List](#associate-items-with-a-list)
    - [Categorising Items using Tags](#categorising-items-using-tags)
    - [Authentication](#authentication)
      - [Create Sessions Table](#create-sessions-table)
      - [Add **`picture`** and **`locale`** to **`person`**](#add-picture-and-locale-to-person)
- [_Next_](#next)
  - [Run the App on `localhost`](#run-the-app-on-localhost)
    - [1. `git clone`](#1-git-clone)
    - [2. Required Environment Variables](#2-required-environment-variables)
    - [3. Install Dependencies](#3-install-dependencies)
    - [4. Create the Database](#4-create-the-database)
    - [Start the App](#start-the-app)

# Why? 🤷

Our goal with this 
[MVP](https://github.com/dwyl/technical-glossary/issues/44)
is to build the **minimal _useable_ App** <br />
that covers our basic "***Capture, Categorize, Complete***"
[**workflow**](https://github.com/dwyl/product-roadmap#what). <br />
It is well-documented, tested
and easy for a _complete beginner_ to run & understand.

The idea is to _ship_ this App to
[Heroku](https://github.com/dwyl/app/issues/231)
and then _use/test_ it (_internally_). <br />
Once we have collected initial feedback,
we can share it with the world!

Once the MVP features are complete,
the code will be merged
into the main
[dwyl/**app**](https://github.com/dwyl/app) 
repo.<br />
However we will also maintian this repo
as a **reference** for **new joiners** <br />
wanting the **most _basic_ version**
of the app to **_learn_**.

# _What_? 💭

A **_hybrid_ note taking**,
**categorization**,
**task and activity** (time) **tracking tool**
with built-in (basic) team **communication**. <br />

We've found it _tedious_ 
to use **several _separate_ apps**
for task/time tracking and comms
and think it's _logical_ 
to _combine_ the functionality.

If the idea of **_combining_ related tools**
appeals to you keep reading. 😍<br />
If it sounds like a _terrible_ idea to you,
please just ignore it and get on with your day. 👌

“_If at first the **idea** is **not absurd**,
then there is **no hope** for it._”
~ [Albert Einstein](https://www.goodreads.com/quotes/110518-if-at-first-the-idea-is-not-absurd-then-there)

## 3 Apps into _One_

This MVP will combine 3 apps into one.
We built the 3 _separate_ apps
to showcase the individual features:

1. Todo list: 
   [github.com/dwyl/phoenix-liveview-**todo-list**](https://github.com/dwyl/phoenix-liveview-todo-list-tutorial)
2. Stop Watch (Timer):
   [github.com/dwyl/phoenix-liveview-**stopwatch**](https://github.com/dwyl/phoenix-liveview-stopwatch)
3. Chat: 
   [github.com/dwyl/phoenix-liveview-**chat**](https://github.com/dwyl/phoenix-liveview-chat-example)

We encourage people to read 
and understand those individual features
from first principals
***`before`***
trying to to understand 
how the MVP works. 
But our _hope_ is that
the UI/UX in the MVP
is sufficiently simple
that it **_immediately_ makes sense**. 

## Tech Stack? 

This **MVP** app uses the **`PETAL` Stack**
described in: 
[dwyl/**technology-stack**](https://github.com/dwyl/technology-stack)

Going through the individual feature apps listed above,
will give you enough knowledge of the stack 
to understand this MVP. 

# _Who?_ 👥

This **MVP** has **_two_ target audiences**:

1. **@dwyl team** to start 
  ["dogfooding"](https://en.wikipedia.org/wiki/Eating_your_own_dog_food)
  the basic workflow in our App. <br />
  It's meant to work for _us_
  and have just enough functionality 
  to solve our basic needs.

2. **Wider community** of people 
  who want to see a **_fully_-functioning `Phoenix` app**
  with good documentation and testing.

_Longer_ term, the MVP 
will also help future @dwyl team members
get 
[**up-to-speed**](https://dictionary.cambridge.org/dictionary/english/up-to-speed) 
on our App & Stack **_much_ faster**.
Understanding the basics in _this_ app
will be an _excellent_ starting point.

## Feedback! 🙏

Your feedback is very much encouraged/welcome! 💬<br />
If you find the repo interesting/useful, please ⭐ on GitHub. <br />
And if you have any questions,
please open an issue:
[app-mvp-phoenix/issues](https://github.com/dwyl/app-mvp-phoenix/issues) ❓
<br />
<!--
If you are using the "full" @dwyl App,
and have a question/idea,
please open an issue in:
[app/issues](https://github.com/dwyl/app/issues)
-->

# _How_? 💻

Our goal is 
to document as much 
of the implementation as possible,
so that _anyone_ 
can follow along.

## Run the MVP App on your `localhost` ⬇️

> **Note**: You will need to have 
**`Elixir`** and **`Postgres` installed**, <br />
see: 
[learn-elixir#installation](https://github.com/dwyl/learn-elixir#installation)
and 
[learn-postgresql#installation](https://github.com/dwyl/learn-postgresql#installation)

On your `localhost`, 
run the following commands 
in your terminal:

```sh
git clone git@github.com:dwyl/app-mvp-phoenix.git && cd app-mvp-phoenix
mix setup
```
That will download the MVP code, 
install dependencies
and create the necessary database + tables.

## _Single_ Environment Variable: `AUTH_API_KEY`

Follow the instructions in **Step 2** of
[**`auth_plug`**](https://github.com/dwyl/auth_plug#2-get-your-auth_api_key-)
to create your 
**`AUTH_API_KEY`**.

Once you've got that setup,
you can run the app with:

```sh
mix phx.server
```

> **`TODO`**: insert **`GIF`** of MVP speed-run once ready.



<br />

# Build Log 👩‍💻

This is a log 
of the steps taken 
to build the MVP.
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

## 0. Prerequisites

Not required, but recommened,
if you're totally new 
to building **`Phoenix`** Apps,
consider following the 
[**/phoenix-chat-example**](https://github.com/dwyl/phoenix-chat-example#0-pre-requisites-before-you-start)
_first_.
At the very least,
check-out the prerequisites there
before you start here.


## 1. Create a New `Phoenix` App

Create a new `Phoenix` app
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

```sh
mix c
```

You should see output similar to the following:

<img width="653" alt="Phoenix tests passing coverage 100%" src="https://user-images.githubusercontent.com/194400/175767439-4f609357-24c0-4975-a3d4-6ed6057bb321.png">

> **Note**: for the **`mix c`** command (alias) to work,
> you need to add a few **`dev`** dependencies in
> [`mix.exs`](https://github.com/dwyl/app-mvp-phoenix/blob/main/mix.exs)
> to track test coverage,
> a 
> [`coveralls.json`](https://github.com/dwyl/app-mvp-phoenix/blob/main/coveralls.json)
> file to exclude `Phoenix` files from `excoveralls` checking
> and the alias (shortcuts) in `mix.exs` `defp aliases do` list.
> e.g: `mix c` runs `mix coveralls.html` 
> see: [**`commits/d6ab5ef`**](https://github.com/dwyl/app-mvp-phoenix/pull/90/commits/d6ab5ef7c2be5dcad7d060e782393ae29c94a526)
> This is just standard `Phoenix` project setup for us, 
> so we don't duplicate any of the steps here.
> For more detail, please see:
> [Automated Testing](https://github.com/dwyl/phoenix-chat-example#testing-our-app-automated-testing)
> in the 
> [dwyl/phoenix-chat-example](https://github.com/dwyl/phoenix-chat-example#testing-our-app-automated-testing)
> and specifically
> [What is _not_ tested?](https://github.com/dwyl/phoenix-chat-example#13-what-is-not-tested)

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

  def render(assigns) do
    AppWeb.AppView.render("capture.html", assigns)
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
**`lib/app_web/templates/app`** 
directory,
then create  
**`lib/app_web/templates/app/capture.html.heex`**
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
mix phx.gen.schema Status status text:string
mix phx.gen.schema Person people givenName:binary auth_provider:string key_id:integer status_id:references:status picture:binary locale:string
mix phx.gen.schema Item items text:string person_id:references:people status:references:status
mix phx.gen.schema Timer timers item_id:references:items start:naive_datetime end:naive_datetime person_id:references:people
```

At the end of this step,
we have the following database
[Entity Relationship Diagram](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model)
(ERD):

![mvp-erd-without-associations](https://user-images.githubusercontent.com/194400/177014286-cefc55e8-510f-44dd-befb-59f6e3315fd7.png)

<!-- probably not needed ...
> **Note**: We used 
> [**`mix phx.gen.schema`**](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html)
> instead of the
[`phx.gen.html`](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Html.html)
generator which creates a _lot_ of 
[boilerplate code](https://github.com/dwyl/app-mvp-phoenix/issues/89#issuecomment-1167548207).
-->

In this step we created **4 database tables**;
`items`, `people`, `status` and `timers`.
Let's run through them.

### _Explanation_ of the Schemas

This is a quick breakdown of the schemas created above:
#### `person`

The `person` _using_ the App
(AKA the ["user"](https://github.com/dwyl/app/issues/33))

+ `id`: `Int`<sup>1</sup>
+ `inserted_at`: `Timestamp` - created/managed by `Phoenix/Ecto`
+ `updated_at`: `Timestamp`
+ `givenName`: `Binary` (_encrypted_) - first name of a person
 https://schema.org/Person
+ `auth_provider`: `String` - so we can contact the person by email duh.
+ `email_hash`: `Binary` (_salted & hashed for quick lookup_)
+ `key_id`: `String` - the `ID` of the encryption key
used to encrypt personal data (NOT the key itself!)
see:
[dwyl/phoenix-ecto-**encryption**-**example**](https://github.com/dwyl/phoenix-ecto-encryption-example)
+ `status_id`: `Int` (**FK** `status.id`) - e.g: "0: unverified, 1: verified", etc.

#### `item`

An `item` is the most basic unit of content.
e.g: a "note", "task", "reminder", etc.
The name **`item`** is **_deliberately_ generic**
as it maintains complete flexibility 
for what we are building later on.

+ `id`: `Int` - the auto-incrementing `id`.
+ `inserted_at`: `Timestamp` - created/managed by `Phoenix`
+ `updated_at`: `Timestamp`
+ `text`: `Binary` (_encrypted_) - the free text you want to capture.
+ `person_id`: `Int` 
  ([**FK**](https://en.wikipedia.org/wiki/Foreign_key)  
    `person.id` the "owner" of the `item`)
+ `status_id`: `Int` (**FK** `status.id`) the `status` of the `item` 
  e.g: "in progress"

#### `status`

The `status` of an `item` or `person`.

+ `id`: `Int`
+ `inserted_at`: `Timestamp`
+ `updated_at`: `Timestamp`
+ `person_id`: `Int` (**FK** `person.id` - the person
    who defined/updated the status)
+ `text`: `String` - examples:
  + "unverified" - for a person that has not verified their email address
  + "verified" - for a person who's identity has been verified.
  + "open"
  + "in_progress"
  + "complete"
  + [etc.](https://github.com/dwyl/checklist/pull/3/files#diff-597edb4596faa11c05c29c0d3a8cf94a)

`status` is _deliberately_ both versatile and limited.
We want to be able to apply a _single_ `status`
to a `person` or `item` at any given time.
i.e. an `item` cannot be `status` `"active"` and `"done"`
at the same time.

<!--
We _could_ have just used `tags` for everything,
e.g. (SQL pseudocode) 

```sql
SELECT * FROM items
JOIN items_tags ON
  item_tags.item_id = item.id
JOIN tags on 
  item_tags.tag_id = tags.id
WHERE
  item.person_id = 42
AND
  tags.text = 'open';
```

However we _prefer_ to have `status` 
_distinct_ from `tags` 
because we feel it makes it 
easier to reason about.

e.g:

```sql
SELECT * FROM items WHERE person_id = 4 AND status_id = 1; -- i.e. 'open'
```

No join required. 
The `status_id = 1`
is defined by the App
so can be hard-coded.

> FYI: the plural form of "status" is "status":
https://english.stackexchange.com/questions/877/plural-form-of-status

-->

#### `timer`

A `timer` is attached to an `item`
to track how long it takes to ***complete***.

  + `id`: `Int`
  + `inserted_at`
  + `item_id` (FK item.id)
  + `start`: `NaiveDateTime` - time started on device
  + `end`: `NaiveDateTime` - time ended on device

An `item` can have zero or more `timers`.
Each time a `item` (`task`) is worked on
a **_new_ `timer`** is started (_and stopped_).
That allows us to get a running total
of the amount of time that has
been taken.

<br />

#### Schema Notes

If naming things is 
[hard](https://martinfowler.com/bliki/TwoHardThings.html),
choosing names for schemas/fields is **_extra_ hard_**,
because once **APIs** are defined
it can be a _mission_ to modify them
because **_changing_ APIs "_breaks_" _everything_**!
We have been thinking about,
researching and iterating on this idea for a _long_ time.
Our _hope_ is that it will be obvious to everyone _why_
a certain database table is named the way it is,
but if not, 
[please open an issue/question](https://github.com/nelsonic/time-mvp-phoenix/issues)
to seek clarification. 

<sup>1</sup> We are using the `default` Phoenix auto-incrementing `id`
for all `id` fields in this MVP. When we _need_ to make the App "offline first"
we will transition to a Globally Unique [ContentID](https://github.com/dwyl/cid)



<br />

### 2.1 Create `item_tags` Association

An `item` should be able 
to have one or more tags associated with it.
To enable this we need a new table 
to store the data.



#### `item_tags`

`item_tags` - are the `tags` applied to an `item`. 
  
+ `item_id` (**FK** item.id)
+ `tag_id` (**FK** tag.id)
+ `inserted_at`


### 2.2 Run Tests!

Once we've created the required schemas,
several new files are created.
see:
[**`commits/6d24085`](https://github.com/dwyl/app-mvp-phoenix/pull/90/commits/6d240852aeb1b2d8c21852575c44153e5a463213)

```sh
mix c
```

As a result of all the new files, 
the test coverage lowers considerably:

```sh
Finished in 0.1 seconds (0.07s async, 0.1s sync)
3 tests, 0 failures

Randomized with seed 586135
----------------
COV    FILE                                        LINES RELEVANT   MISSED
  0.0% lib/app/item.ex                                19        2        2
  0.0% lib/app/list.ex                                20        2        2
  0.0% lib/app/person.ex                              23        2        2
  0.0% lib/app/status.ex                              17        2        2
  0.0% lib/app/tag.ex                                 17        2        2
  0.0% lib/app/timer.ex                               20        2        2
100.0% lib/app_web/live/app_live.ex                   11        2        0
100.0% lib/app_web/router.ex                          18        2        0
  0.0% lib/app_web/views/app_view.ex                   3        0        0
100.0% lib/app_web/views/error_view.ex                16        1        0
  0.0% lib/app_web/views/layout_view.ex                7        0        0
[TOTAL]  29.4%
----------------
```

Just be _aware_ of this.
We _could_ write tests to (_artificially_) cover
these lines of code.
However, we are going to add tests 
as we define the _functionality_.

<br />







## _Create_ Schemas

We want to be able to create, edit/update and view
all records in the database therefore we want
[`phx.gen.html`](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Html.html)
with views, so that we get "free" UI for creating/updating the data.


We will need to add `person_id` to a `tag` and `status` _after_
the person schema has been created.
Person references `tags` and `status`
(_i.e. there is a circular reference.
  but it's fine, don't worry!_
  see: https://dba.stackexchange.com/questions/102903/circular-foreign-key-references ).


This is the order in which the schemas need to be created
so that related tables can reference each other.
For example: People references Tags and Status
so those need to be created first.

<!--
If you make a mistake during the running of these phx.gen.html commands
or need to change something e.g: github.com/dwyl/app/issues/232
your best course of action is:
rm -rf lib priv test assets config
psql -U postgres -c 'DROP DATABASE IF EXISTS app_dev;'
psql -U postgres -c 'DROP DATABASE IF EXISTS app_test;'
mix new app

mix ecto.create
-->

Create a new Phoenix App:
```
mix phx.new app
```
When asked to install the dependencies,
type `Y` and `[Enter]` (_to install everything_)

Next we will run the generator commands
to create all the schemas:
```
mix phx.gen.html Ctx Tag tags text:string
mix phx.gen.html Ctx Status status text:string
mix phx.gen.html Ctx Person people username:binary username_hash:binary email:binary email_hash:binary givenName:binary familyName:binary password_hash:binary key_id:integer status:references:status tag:references:tags
mix phx.gen.html Ctx Item items text:string person_id:references:people status:references:status
mix phx.gen.html Ctx List lists title:string person_id:references:people status:references:status tag:references:tags
mix phx.gen.html Ctx Timer timers item_id:references:items start:naive_datetime end:naive_datetime person_id:references:people
```

Once all those `mix phx.gen.html` commands have been run,
open the `lib/app_web/router.ex` file in your editor:

locate the section:
```elixir
scope "/", AppWeb do
  pipe_through :browser

  get "/", PageController, :index
end
```
And below the `get "/", PageController, :index` line, add the following lines:

```
 # generic resources for schemas:
  resources "/items", ItemController
  resources "/lists", ListController
  resources "/people", PersonController
  resources "/status", StatusController
  resources "/tags", TagController
  resources "/timers", TimerController
```
Your `lib/app_web/router.ex`
should look like this:
[lib/app_web/router.ex#L16-L28](https://github.com/dwyl/app-mvp-phoenix/blob/851a1a4c87ef1474b55ee42cc09ed7695334d4a7/lib/app_web/router.ex#L16-L28)


After running these `phx.gen` commands,
and running both `mix ecto.create` and `mix ecto.migrate`,
we have the following Entity Relationship (ER) diagram:

![app-mvp-er-diagram](https://user-images.githubusercontent.com/194400/68760839-ac659700-060a-11ea-9eef-5767022e0d12.png)

We now need to add `person_id` to `tags` and `status`
to ensure that a human has ownership over those records.


```sh
mix ecto.gen.migration add_person_id_to_tag
mix ecto.gen.migration add_person_id_to_status
```


Code additions:
+ Add `person_id` to `tags`:
[1dc6630](https://github.com/dwyl/app-mvp-phoenix/pull/18/commits/1dc66303e3ee23bec3dfc1bac87a9c7b80db964a)
+ Add `person_id` to `status`:
[4685a91](https://github.com/dwyl/app-mvp-phoenix/pull/18/commits/4685a911b4af5bf4e2bd4e934af2237ba966bcb4)

ER Diagram With the `person_id` field
added to the `tags` and `status` tables:

![app-er-diagram-person_id-status-kind](https://user-images.githubusercontent.com/194400/68773176-04a89300-0623-11ea-94fa-eff32acc4724.png)


### Associate Items with a List

An item will always be on a list even if the list only has one item.
By `default` the list an item will be associated with is "uncategorised".

Let's create the migration to link `items` to `lists`:

```
mix ecto.gen.migration create_list_items_association
```

With the migration file we need to edit the following files:

Open the `lib/app/ctx/item.ex` file, locate the `schema` block:
```elixir
schema "items" do
  field :text, :string
  field :human_id, :id
  field :status, :id

  timestamps()
end
```

Add the line `belongs_to :list, App.Ctx.List`
such that your `schema` now looks like this:

```elixir
schema "items" do
  field :text, :string
  field :human_id, :id
  field :status, :id
  belongs_to :list, App.Ctx.List # an item can be linked to a list

  timestamps()
end
```


Open the `lib/app/ctx/list.ex` file
and locate the `schema` block.
Add the line `has_many :items, App.Ctx.Item`
such that your `schema` now looks like this:

```diff
  schema "lists" do
    field :title, :string
    field :person_id, :id
    field :status, :id
+   has_many :items, App.Ctx.Item # lists have one or more items

    timestamps()
  end
```

Open the newly created migration file:
`priv/repo/migrations/{timestamp}_create_list_items_association.exs` <br />
and add the following code to the `change` block:
```elixir
def change do
  create table(:list_items) do
    add :item_id, references(:items)
    add :list_id, references(:lists)

    timestamps()
  end

  create unique_index(:list_items, [:item_id, :list_id])
end
```

That will create a lookup table to associate items to a list. <br />
Code snapshot:
https://github.com/nelsonic/time-mvp-phoenix/commit/935eac1251580c13b45d9341f0597e4118f1a66f


> **Note**: we are not imposing a restriction
(_at the database level_)
on how many lists an item can belong to in the `list_items` table.
The only restriction is in the `items` schema
`has_one :list, App.Ctx.List`.
But this can easily be updated to `has_many`
if/when the use case is validated.
See:
[time-mvp-phoenix/issues/12](https://github.com/nelsonic/time-mvp-phoenix/issues/12)


After saving the above files, run `mix ecto.migrate`.
Now when you view the Entity Relationship Diagram
it should look like this:

![app-er-diagram-with-list_items](https://user-images.githubusercontent.com/194400/68774230-ae3c5400-0624-11ea-8316-179c5b6eb1a4.png)

### Categorising Items using Tags

An `item` can have _multiple_ `tags`,
let's make that happen with an `item_tags` table:


```
mix ecto.gen.migration create_item_tags_association
```

Open the newly created migration file
`priv/repo/migrations/{timestamp}_create_item_tags_association.exs` <br />
and add the following code to the `change` block:
```elixir
def change do
  create table(:item_tags) do
    add :item_id, references(:items)
    add :tag_id, references(:tags)

    timestamps()
  end

  create unique_index(:item_tags, [:item_id, :tag_id])
end
```

Now run the `mix ecto.migrate` script.
The Entity Relationship Diagram (ERD)
should now look like this:

![app-er-diagram-with-item_tags](https://user-images.githubusercontent.com/194400/68804955-c62eca80-065a-11ea-888b-9391154aceda.png)


### Authentication

With the addition of Sign in with Google
using [**`elixir-auth-google`**](https://github.com/dwyl/elixir-auth-google),
a **`sessions`** table was added to store session data
and the **`picture`** and **`locale`** fields were added to the **`person`**:

#### Create Sessions Table

```
mix phx.gen.html Ctx Session sessions auth_token:binary refresh_token:binary key_id:int person_id:references:people
```


#### Add **`picture`** and **`locale`** to **`person`**

```
mix ecto.gen.migration add_picture_locale_to_people
```

Open the resulting migration file e.g:
[`/priv/repo/migrations/20191130210036_add_picture_locale_to_people.exs`](https://github.com/dwyl/app-mvp-phoenix/blob/master/priv/repo/migrations/20191130210036_add_picture_locale_to_people.exs)
and update the code to look like this:

```elixir
defmodule App.Repo.Migrations.AddPictureLocaleToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :picture, :binary
      add :locale, :string, default: "en"
    end
  end
end
```

Now run `mix ecto.migrate` and your ER diagram should look like this:


![ER-diagram-with-sessions](https://user-images.githubusercontent.com/194400/73312103-db5dd300-421f-11ea-92b5-e81bce094333.png)


# _Next_

Build the basic _capture_ stage:
https://github.com/dwyl/app/issues/234


<br /><br />



## Run the App on `localhost`

If you want to _run_ this App on your `localhost`,
please _first_ ensure that you have PostgreSQL installed.
see:
[Prerequisites](https://github.com/dwyl/phoenix-chat-example#0-pre-requisites-before-you-start)

### 1. `git clone`

Clone the repository from GitHub:

```
git clone git@github.com:dwyl/app-mvp-phoenix.git && cd app-mvp-phoenix
```

### 2. Required Environment Variables

Create an `.env` file to store the required environment variables:
```sh
cp .env_sample .env
```

The
[`.env_sample`](https://github.com/dwyl/app-mvp-phoenix/blob/master/.env_sample)
file shows which environment variables are required.

For running on `localhost`, you will only need to change the values
for `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` to _real_ values
in order for Google Auth to work.
For that you will need to follow the instructions:
[create-google-app-guide.md](https://github.com/dwyl/elixir-auth-google/blob/master/create-google-app-guide.md)

> If you are new to Environment Variables, please see:
[dwyl/**learn-environment-variables**](https://github.com/dwyl/learn-environment-variables)

Once you have updated the `.env` file with the
`GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` API keys
you have everything you need to run the app.

Run `source .env` in your terminal
to load the environment variables.

### 3. Install Dependencies

Install the `Elixir` dependencies by running

```
mix deps.get
```

Install Node.js dependencies by running:

```
cd assets && npm install && cd ..
```


### 4. Create the Database

Create and migrate your database with the command:
```
mix ecto.setup
```
That should create a new database called `app_dev`.


### Start the App

Finally once everything is installed and the DB is created,
run the app:

```
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) in your web browser.
You should see something similar to the following:

![app-running-on-localhost](https://user-images.githubusercontent.com/194400/73284024-df6ffd80-41eb-11ea-967f-c1eec086fe99.png)

Or if the homepage has changed,
see: https://dwylapp.herokuapp.com
and compare!
