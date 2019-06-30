# Time MVP `Phoenix`

A `Elixir`/`Phoenix` implementation of the Time MVP feature set.

# Why?

Our objective with this MVP
is to build the minimal useable App,
that is well-documented, tested
and easy for a _beginner_ to understand.

Our goal is to _ship_ this App to Heroku
and _use_ it (_internally_).
Once we have collected initial feedback,
we will implement Authentication
and share it with the world!

# _What_?

A _hybrid_ list management and activity (time) tracking tool.
If this sounds like a _terrible_ idea to you, please just ignore this repo.


# _How_?


## Schema

If naming things is [hard](https://martinfowler.com/bliki/TwoHardThings.html),
choosing names for schemas/fields is _extra difficult_,
because once APIs are defined they can be a _mission_ to modify
because they "_break_" _everything_!
We have been thinking about,
researching and iterating on this idea for a _long_ time.


+ `list`<sup>1</sup> - a collection of items
  + `id`: `Int` - we will make this a
  a Globally Unique [ContentID](https://github.com/dwyl/cid) when needed.
  + `kind`<sup>1</sup>: `Enum` - , "checklist", "reading", "shopping",
    (_we will add to this list of types as required_)
  + `order`: `Enum` - "alpha", "date", "priority", "unordered"
  + `title`: `String` - "Alex's Todo List"


+ `list_kind` - the _types_<sup>2</sup> of list that can be created
  + `id`: `Int`
  + `name`: `String` - examples:
    + "task"
    + "checklist"
    + "reading"
    + "shopping"
    + "exercise"

The "kinds" of list will be crowd-sourced but will need to be curated
to avoid duplication and noise. For now we only need "task".


+ `list_items`
  + `item_id` (FK item.id)
  + `list_id` (FK list.id)
  + `inserted_at`


+ `item` - a basic unit of content
  + `id`: `Int`
  + `inserted_at`
  + `updated_at`
  + `kind`: `Enum` - "note", "task", ""
  + `text`: `String`


+ `link` -
  + `id`: `Int`
  + `url`: `String`
  + `item_id` (FK item.id)


+ `timer` - a timer attached to an item. an item can have multiple timers.
  + `id`: `Int`
  + `item_id` (FK item.id)
  + `start`: `NaiveDateTime`
  + `end`: `NaiveDateTime`


+ `event` - when an item has dates & times associated,
  + `id`: `Int`
  + `item_id` (FK item.id)
  + `start`: `NaiveDateTime`
  + `end`: `NaiveDateTime`


<sup>1</sup> The word "list" is meaningful in many programming languages. <br />
+ Elm: https://package.elm-lang.org/packages/elm/core/latest/List
+ Elixir: https://hexdocs.pm/elixir/List.html
+ Python: https://docs.python.org/3/tutorial/datastructures.html
+ etc.
We have chosen to use it as it's also the most obvious word in _english_.

<sup>2</sup> We expect people to define their own kinds of lists
Research kinds of list:
+ Types<sup>2</sup> of lists:
https://gist.github.com/shazow/2467329/f79c169b49831057c4ec705910c4e11df043e768
+ https://www.lifehack.org/articles/featured/12-lists-that-help-you-get-things-done.html


<sup>3</sup> We cannot use the word "type" as a field name,
because it will be confusing in programming languages
where `type` is either a reserved word or a language construct.
see: https://en.wikipedia.org/wiki/Type_system
Our "second choice" is the word "**kind**",
which is defined as: "_a group of things having similar characteristics_".
see: https://www.google.com/search?q=define+kind
Many thesaurus have "kind" and "type" as synonyms.
We feel this is the best choice because it's easy
for a beginner or non-native english speaker to understand.
e.g: <br />
**Q**: "What kind of list is it?" <br />
**A**: "It is a shopping list." <br />

**Note**: while "kind" is a term in Type Theory,
see: https://en.wikipedia.org/wiki/Kind_(type_theory) <br />
it is _not_ a reserved word in any of the programming languages we know/use:
+ HTML: https://developer.mozilla.org/en-US/docs/Web/HTML/Element
+ CSS: https://developer.mozilla.org/en-US/docs/Web/CSS/Reference
+ Elixir: https://hexdocs.pm/elixir/master/syntax-reference.html
+ Erlang: http://erlang.org/doc/reference_manual/data_types.html
+ Go: https://golang.org/ref/spec
+ Haskell: https://wiki.haskell.org/Keywords
+ JavaScript:
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar#Keywords
+ Java: https://en.wikipedia.org/wiki/List_of_Java_keywords
+ Kotlin: https://kotlinlang.org/docs/reference/keyword-reference.html
+ Rust: https://doc.rust-lang.org/reference/keywords.html
+ Python: https://stackoverflow.com/questions/9642087/list-of-keywords-in-python
+ C++: https://en.cppreference.com/w/cpp/keyword
+ Swift: https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html
+ Ruby: https://docs.ruby-lang.org/en/2.2.0/keywords_rdoc.html
+ PHP: https://www.php.net/manual/en/reserved.keywords.php

We have not considered any "Esoteric"
https://en.wikipedia.org/wiki/Esoteric_programming_language
or non-english programming languages
https://en.wikipedia.org/wiki/Non-English-based_programming_languages
because an exhaustive search is impractical.




To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
