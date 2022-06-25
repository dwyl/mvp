<div align="center">

# @dwyl App MVP `Phoenix`  💡⏳ ✅

A Phoenix`implementation
of the @dwyl App [MVP feature set](https://github.com/dwyl/app/issues/266).

[![Build Status](https://img.shields.io/travis/com/dwyl/app-mvp-phoenix/master?color=bright-green&style=flat-square)](https://travis-ci.org/dwyl/app-mvp-phoenix)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/app-mvp-phoenix/master.svg?style=flat-square)](https://codecov.io/github/dwyl/app-mvp-phoenix?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/elixir_auth_google?color=brightgreen&style=flat-square)](https://hex.pm/packages/elixir_auth_google)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/app-mvp-phoenix/issues)
[![HitCount](https://hits.dwyl.com/dwyl/app-mvp-phoenix.svg)](https://hits.dwyl.com/dwyl/app-mvp-phoenix)


  <a href="https://agilevelocity.com/product-owner/mvp-mmf-psi-wtf-part-one-understanding-the-mvp">
    <img src="https://user-images.githubusercontent.com/194400/65666966-b28dbd00-e036-11e9-9d11-1f5d3e22258e.png" width="500" alt="MVP Loop">
  </a>
</div>




# Why? 🤷

Our goal with this 
[MVP](https://github.com/dwyl/technical-glossary/issues/44)
is to build the **minimal _useable_ App** <br />
that covers our basic "***Capture, Categorize, Complete***"
[**workflow**](https://github.com/dwyl/product-roadmap#what). <br />
It is well-documented, tested
and easy for a _complte beginner_ to run/understand.

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
**task and activity** (time) **tracking tool**. <br />

We've found it _tedious_ 
to use **two _separate_ apps**
for task and time tracking <br />
and think it's _logical_ 
to _combine_ the functionality.

If the idea of **_combining_ related tools**
appeals to you keep reading. 😍<br />
If it sounds like a _terrible_ idea to you,
please just ignore it and get on with your day. 👌

“_If at first the **idea** is **not absurd**,
then there is **no hope** for it._”
~ [Albert Einstein](https://www.goodreads.com/quotes/110518-if-at-first-the-idea-is-not-absurd-then-there)

## Tech Stack? 

This **MVP** app uses the **`PETAL` Stack**
described in: 
[dwyl/**technology-stack**](https://github.com/dwyl/technology-stack)

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
get **up-to-speed** on our App/Stack **_much_ faster**,
because they won't have to "grok" 100k+ lines of code;
understanding the basic in _this_ app
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

On your localhost run the following in your terminal:

```sh
git clone git@github.com:dwyl/app-mvp-phoenix.git && cd app-mvp-phoenix
mix setup
```
That should download the code, 
install dependencies 
and create the necessary database + tables.




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

> **Note**: in our case 
> we added a few **`dev`** dependencies in
> [`mix.exs`](https://github.com/dwyl/app-mvp-phoenix/blob/main/mix.exs)
> to track test coverage,
> a 
> [`coveralls.json`](https://github.com/dwyl/app-mvp-phoenix/blob/main/coveralls.json)
> file to exclude `Phoenix` files from `excoveralls` checking
> and add a few aliases (shortcuts)
> see: [**`commits/d6ab5ef`**](https://github.com/dwyl/app-mvp-phoenix/pull/90/commits/d6ab5ef7c2be5dcad7d060e782393ae29c94a526)
> This is just standard `Phoenix` project setup.
> So we don't explain any of the steps here.
> For more detail, please see:
> [Automated Testing](https://github.com/dwyl/phoenix-chat-example#testing-our-app-automated-testing)
> in the 
> [dwyl/phoenix-chat-example](https://github.com/dwyl/phoenix-chat-example#testing-our-app-automated-testing)
> and specifically
> [What is _not_ tested?](https://github.com/dwyl/phoenix-chat-example#13-what-is-not-tested)

### 1.3 Setup `Tailwind`

As we're using **`Tailwind CSS`**
for the **UI** in this project

We are not duplicating the instructions here,
please refer to:
[Tailwind in Phoenix](https://github.com/dwyl/learn-tailwind#part-2-tailwind-in-phoenix).



By the end of this step you should have **`Tailwind`** working,
when you visit 
[`localhost:4000`](http://localhost:4000) 
in your browser.
e.g: 

![hello world tailwind phoenix](https://user-images.githubusercontent.com/194400/174838767-20bf201e-3179-4ff9-8d5d-751295d1d069.png)

If you got stuck in this section,
please open an issue:
[learn-tailwind/issues](https://github.com/dwyl/learn-tailwind/issues)


## 2. Create Schema to Store Data

By the end of the schema creation step 
we will have the following database
Entity Relationship Diagram (ERD):






## Schema

Let's dive straight into defining the tables and fields for our project!
This is the "data first" approach. 

+ `person` - the person using the App
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


+ `item` - a basic unit of content. e.g: a "note", "task" or "reminder"
  + `id`: `Int`
  + `inserted_at`: `Timestamp` - created/managed by `Phoenix`
  + `updated_at`: `Timestamp`
  + `text`: `Binary` (_encrypted_) - the free text you want to capture.
  + `person_id`: `Int` (**FK** `person.id` the "owner" of the item)
  + `status_id`: `Int` (**FK** `status.id`) the `status` of the `item` 
    e.g: "in progress"


+ `tag` - _tags_<sup>2</sup> can be applied to an `item` to ***Categorise*** it.
  + `id`: `Int`
  + `inserted_at`: `Timestamp`
  + `updated_at`: `Timestamp`
  + `person_id`: `Int` (**FK** `person.id` -
      the person who defined or last updated the `tag.text`)
  + `text`: `String` - examples:
    + "note"
    + "task"
    + "checklist"
    + "reading"
    + "shopping"
    + "exercise"
    + ["reminder"](https://github.com/nelsonic/time-mvp-phoenix/issues/5)
    + "quote"
    + "memo" - https://en.wikipedia.org/wiki/Memorandum
    + "image" - a link to an image stored on a file system (e.g: IPFS or S3)
    + "author" - in the case of a book author
<!--    + ["link"](https://github.com/nelsonic/time-mvp-phoenix/issues/4) -->

+ `item_tags`
  + `item_id` (**FK** item.id)
  + `tag_id` (**FK** tag.id)
  + `inserted_at`


+ `status` - the status of an item or person
  + `id`: `Int`
  + `inserted_at`: `Timestamp`
  + `updated_at`: `Timestamp`
  + `person_id`: `Int` (**FK** `person.id` - the person
      who defined/updated the status)
  + `text`: `String` - examples:
    + "unverified" - for a person that has not verified their email address
    + "open"
    + "complete"
    + [etc.](https://github.com/dwyl/checklist/pull/3/files#diff-597edb4596faa11c05c29c0d3a8cf94a)

> Plural form of "status" is "status":
https://english.stackexchange.com/questions/877/what-is-plural-form-of-status


+ `list`<sup>3</sup> - a collection of items
  + `id`: `Int`<sup>1</sup>
  + `title`: `String` - e.g: "_Alex's Todo List_"
  + `order`: `Int` - Enum ["alphabetical", "date", "priority", "unordered"]
  + `status`: `Int` (**FK** `status.id`)

+ `list_items`
  + `item_id` (FK item.id)
  + `list_id` (FK list.id)
  + `inserted_at`

+ `timer` - A timer attached to an `item`. An `item` can have _multiple_ timers.
  + `id`: `Int`
  + `inserted_at`
  + `item_id` (FK item.id)
  + `start`: `NaiveDateTime` - time started on device
  + `end`: `NaiveDateTime` - time ended on device


### Schema Notes

If naming things is [hard](https://martinfowler.com/bliki/TwoHardThings.html),
choosing names for schemas/fields is _extra difficult_,
because once APIs are defined
it can be a _mission_ to modify them
because changing APIs "_breaks_" _everything_!
We have been thinking about,
researching and iterating on this idea for a _long_ time.
Hopefully it will be obvious to everyone _why_
a certain field is named the way it is,
but if not, please open an
[issue/question](https://github.com/nelsonic/time-mvp-phoenix/issues)
to seek clarification.


<sup>1</sup> We are using the `default` Phoenix auto-incrementing `id`
for all `id` fields in this MVP. When we _need_ to make the App "offline first"
we will transition to a Globally Unique [ContentID](https://github.com/dwyl/cid)

<sup>2</sup> We expect (_and will encourage_) people to define their own tags.
When creating tags, the UI will
[_auto-suggest_](https://github.com/dwyl/app/issues/224)
existing (public/curated) tags
to avoid duplication and noise.
For now we only need "task". <br />


<sup>3</sup>
A "list" is a way of grouping items of content. <br />
An "essay" or "blog post" is a list of notes. <br />
A "task list" (_or "todo list" if you prefer_) is a list of tasks.

We are well aware that the word "list"
is meaningful in many programming languages. <br />
+ Elm: https://package.elm-lang.org/packages/elm/core/latest/List
+ Elixir: https://hexdocs.pm/elixir/List.html
+ Python: https://docs.python.org/3/tutorial/datastructures.html
+ etc.

We have chosen to use "list" as it's the most obvious word in _english_. <br />
We did not find a suitable synonym:
https://www.thesaurus.com/browse/list 🔍 🤷‍

<sup>4</sup> We cannot use the word "type" as a field name,
because it will be confusing in programming languages
where `type` is either a reserved word or a language construct.
see: https://en.wikipedia.org/wiki/Type_system
Instead we are using the term **`tag`**
which is relatively familiar to people
and has the benefit of being both a noun and a verb.
So the expression "tagging" the data works.


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
