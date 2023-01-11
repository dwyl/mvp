<div align="center">

# @dwyl App MVP 💡 ⏳ ✅

The most basic version
of the **@dwyl App**
[**MVP** feature set](https://github.com/dwyl/app/issues/266).

# _Please `try` it_: [mvp.fly.dev](https://mvp.fly.dev/) 🙏

And help us to ...

<a href="https://agilevelocity.com/product-owner/mvp-mmf-psi-wtf-part-one-understanding-the-mvp">
  <img src="https://user-images.githubusercontent.com/194400/65666966-b28dbd00-e036-11e9-9d11-1f5d3e22258e.png" width="500" alt="MVP Loop">
</a>

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/dwyl/mvp/ci.yml?label=build&style=flat-square&branch=main)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/mvp/main.svg?style=flat-square)](http://codecov.io/github/dwyl/mvp?branch=main)
[![Hex.pm](https://img.shields.io/hexpm/v/elixir_auth_google?color=brightgreen&style=flat-square)](https://hex.pm/packages/elixir_auth_google)
[![contributions welcome](https://img.shields.io/badge/feedback-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/app-mvp/issues)
[![HitCount](https://hits.dwyl.com/dwyl/app-mvp.svg)](https://hits.dwyl.com/dwyl/app-mvp)


</div>
<br />

- [@dwyl App MVP 💡 ⏳ ✅](#dwyl-app-mvp---)
- [_Please `try` it_: mvp.fly.dev 🙏](#please-try-it-mvpflydev-)
- [Why? 🤷‍♀️](#why-️)
- [_What_? 💭](#what-)
  - [MVP? 🚧](#mvp-)
  - [Two Apps in _One_ ✌️](#two-apps-in-one-️)
    - [Proposed MVP UI/UX 💡](#proposed-mvp-uiux-)
- [_Who?_ 👥](#who-)
  - [Feedback! 🙏](#feedback-)
    - [Perform Some Actions in the App 📱](#perform-some-actions-in-the-app-)
- [_How_? 💻](#how-)
  - [Tech Stack? 🧰](#tech-stack-)
  - [Run the MVP App on your `localhost` ⬇️](#run-the-mvp-app-on-your-localhost-️)
  - [_Build_ It! 👷‍♀️](#build-it-️)
  - [Contributing 👩‍💻](#contributing-)
    - [More Features? 🔔](#more-features-)

# Why? 🤷‍♀️ 

Our goal with this
[MVP](https://github.com/dwyl/technical-glossary/issues/44)
is to build the **minimal _usable_ App** <br />
that covers our basic "***Capture, Categorize, Complete***"
[**workflow**](https://github.com/dwyl/product-roadmap#what). <br />
It is well-documented, tested
and easy for a beginner to run & understand.

We _shipped_ the App to
Fly: 
[mvp.fly.dev](https://mvp.fly.dev/)
and _use/test_ it (_internally_). <br />
After collecting initial feedback,
we will integrate it into the main
[dwyl/**app**](https://github.com/dwyl/app) 
repo.<br />
We maintain this repo
as a **reference** for **new joiners** <br />
wanting the **most _basic_ version**
to **learn** from.

<!-- going to move this somewhere else ...
## But _Why_...? 

Our 
[why](https://www.ted.com/talks/simon_sinek_how_great_leaders_inspire_action)
for building this MVP
(and subsequent [App](https://github.com/dwyl/app))
is that we felt the 
[_pain_](https://github.com/dwyl/app/issues/213#issuecomment-650531694)
of _not_ having it!

![nelson-persona](https://user-images.githubusercontent.com/194400/85919307-faf63780-b861-11ea-959c-6a16f0d251fb.png)

If you have feel the pain of
lacking focus/priority,
not knowing what to work on now/next
or suffer from 
[procrastination](https://github.com/nelsonic/nelsonic.github.io/issues/849),
then you too have the problem we ~~have~~ _are fixing_!

We consider the problem of knowing what to work on,
how to prioritise work
and keep track of it
to be a 
["keystone"](https://en.wikipedia.org/wiki/Keystone_(architecture)#Metaphor)
to what we want to build in the 
[future](https://github.com/dwyl/phase-two).
If you _agree_,
please let us know.

## Startup Ideas? 💡

We _love_ talking about startup ideas. ❤️ 🎉 <br />
If you are new to this, 
we recommend watching the following
[YC](https://www.ycombinator.com/)
videos:

+ Jared Friedman's
_How to Get Startup Ideas_:
[youtu.be/uvw-u99yj8w](https://youtu.be/uvw-u99yj8w?t=424)
+ Michael Seibel's
_How to Get and Test Startup Ideas_:
[youtu.be/vDXkpJw16os](https://youtu.be/vDXkpJw16os)
+ Kevin Hale's _How to Evaluate Startup Ideas_:
https://youtu.be/DOtCl5PU8F0

<br />
-->

# _What_? 💭

A **mobile-first** 
**_hybrid_**
**task and activity** (time)
**tracking tool**.
<!-- with built-in (basic) team **communication**. -->

## MVP? 🚧

A Minimum Viable Product (MVP),
as its' name suggests,
is the _minimum_ 
we can do to test the idea.

> If you're new to MVPs, 
> the Wikipedia article is a good starting point:
[wikipedia.org/wiki/Minimum_viable_product](https://en.wikipedia.org/wiki/Minimum_viable_product) <br />
> Or listen to Eric Ries describe it in 3 minutes:
> https://youtu.be/1FoCbbbcYT8 <br />
> Validate your business idea: 
> THE LEAN STARTUP by Eric Ries:
> https://youtu.be/QaoVWtLX038 <br />
> Building Minimal Viable Product with Michael Seibel UC Berkeley Course:
> https://youtu.be/m4isFputh68?t=75 <br />
> How _Not_ To Start A Startup | Michael Seibel: 
> https://youtu.be/9tq-lTjTu2Q?t=413


## Two Apps in _One_ ✌️

We've found it _tedious_ 
to use **several _separate_ apps**
for task and time tracking 🤦‍♂️ <br />
and think it's _logical_ 
to _combine_ the functionality. 
This MVP combines **two apps** into ***one***. 💡

In our journey 
to understand the features we want
from 
[first principles](https://fs.blog/first-principles/),
we **built** the two _separate_ apps:

1. Todo list: 
   [github.com/dwyl/phoenix-liveview-**todo-list**](https://github.com/dwyl/phoenix-liveview-todo-list-tutorial)
2. Stop Watch (Timer):
   [github.com/dwyl/phoenix-liveview-**stopwatch**](https://github.com/dwyl/phoenix-liveview-stopwatch)
<!--
3. Chat (Communication): 
   [github.com/dwyl/phoenix-liveview-**chat**](https://github.com/dwyl/phoenix-liveview-chat-example)
--> 

We encourage you to read 
and understand the individual feature Apps
***`before`***
trying to run the MVP. 👀<br />
But our hope is that
the UI/UX in the MVP
is sufficiently intuitive
that it **_immediately_ makes sense**. 🤞

### Proposed MVP UI/UX 💡

This is our wireframe UI/UX
we used as the _guide_ 
to create the MVP functionality:

![mvp-proposed-ux](https://user-images.githubusercontent.com/194400/73374277-d9445480-42b1-11ea-980a-3fabbfe5a9fd.png)

The idea is a todo list
that tracks how much time
we spend on a task. 

It's _deliberately_ "basic" 
and 
["ugly"](https://youtu.be/m4isFputh68?t=158)
so we _don't_ focus on aesthetics. 🚀<br />
It will _definitely_ change over time 
as we _use_ the App 
and collect _feedback_. 💬<br />
If you want to _help_ make it better,
[share your thoughts!](https://github.com/dwyl/app-mvp/issues/) 🙏

More detail on the MVP features: 
[dwyl/app/issues/265](https://github.com/dwyl/app/issues/265)

<br />

# _Who?_ 👥

This **MVP** has **_two_ target audiences**:

1. **@dwyl team** to 
  ["dogfood"](https://en.wikipedia.org/wiki/Eating_your_own_dog_food)
  the basic workflow in our App. <br />
  It's meant to work for _us_
  and have just enough functionality 
  to solve our _basic_ needs.

2. **Wider community** of people 
  who want to see a 
  **_fully_-functioning `Phoenix` app**
  with good documentation and testing.

_Longer_ term, the MVP 
will help future @dwyl team members
get 
[**up-to-speed**](https://dictionary.cambridge.org/dictionary/english/up-to-speed) 
on our App & Stack **_much_ faster**.

## Feedback! 🙏

Your feedback is very much encouraged/welcome! 💬<br />
If you find the repo interesting/useful, please ⭐ on GitHub. <br />
And if you have any questions,
please open an issue:
[app-mvp/issues](https://github.com/dwyl/app-mvp/issues) ❓
<br />


### Perform Some Actions in the App 📱

Please visit 
[`mvp.fly.dev`](https://mvp.fly.dev/) 
(_or run the app on your `localhost` - see below_) <br />
and perform some actions to test the App:

1. ***Create*** a todo list `item`; <br />
   > Note: this item is **`public`** (anyone can see it!) <br />
   If you want **`private`** items you need to **login**. 
2. ***Start*** a `timer` for the (`public`) `item`
3. ***Stop*** the `timer` for the `item` (press **`start`**)
4. ***Mark*** the `item` as `done` (press/tap the `checkbox` to the left of the `item.text`)
5. ***Click*** on the `done` tab and **`archive`** the `item` (it will disappear)
6. ***Click*** on the `archived` tab and you will see your archived item
7. ***Create*** a new (`public`) `item`.
8. ***Start*** a `timer` for the (`public`) `item` and leave it running
9. ***Login*** using your **`GitHub`** or **`Google`** account.
10. ***Create*** a todo list `item` while logged-in with a `tag`.
11. ***Start*** a `timer` for the `item`
12. ***Stop*** the `timer`
13. ***Resume*** the `timer` that you just stopped.
14. ***Create*** a new (`private`) todo list `item` while logged-in with a different `tag`
15. ***Start*** a `timer` for the `item` 
16. ***Open*** a second web browser and watch the ***realtime sync***!
17. ***Click*** on the first private `item` `tag` and see the filtered list of `items` with that `tag`
18. ***Click*** on the `active` tab or go back in the browser
19. ***Mark*** the first `item` you created as `done`
20. ***Edit*** the remaining `item` text for the timer that is already running.
21. ***Mark*** the (`private`) `item` as `done` and see the time it took.
22. ***`Archive`*** the `item`
24. ***Click*** on the `tags` label on the navbar to check the `tag`s created.
25. ***Go back***
26. ***Logout*** of the app
27. ***View*** the (`public`) `item` you created earlier with the `timer` still running.

That's it. 
The MVP in a nutshell. 
Here's a **`GIF`** 
if you're low on time:

![speedrun](https://user-images.githubusercontent.com/17494745/198015908-40b08f1a-4f5c-4058-9ec8-dd90c4140edc.gif)

The **`GIF`** showcases the (todo list) `items`, 
`tag` filtering and `timers`
being synched across 2 browsers
(one desktop and another mimicking mobile)
in realtime.


<br />

# _How_? 💻

Our goal is 
to document as much 
of the implementation as possible,
so that _anyone_ 
can follow along.

If you spot a gap in the docs,
please 
[let us know!](https://github.com/dwyl/app-mvp/issues)


## Tech Stack? 🧰

This **MVP** app uses the **`PETAL` Stack**
described in: 
[dwyl/**technology-stack**](https://github.com/dwyl/technology-stack)

Going through the individual feature apps listed 
[above](#two-apps-in-one-️)
will give you the knowledge
to understand this MVP.

If you have _any_ coding skills 
(e.g: `JavaScript`, `Java`,  `Python`, 
`Ruby`, `PHP`, `SQL`, etc.) <br />
you will be able to follow along
without much difficulty
as the code is **_deliberately_ simple**.

## Run the MVP App on your `localhost` ⬇️

> **Note**: You will need to have 
**`Elixir`** and **`Postgres` installed**, <br />
see: 
[learn-elixir#installation](https://github.com/dwyl/learn-elixir#installation)
and 
[learn-postgresql#installation](https://github.com/dwyl/learn-postgresql#installation)

> **Tip**: check the prerequisites in:
> [**/phoenix-chat-example**](https://github.com/dwyl/phoenix-chat-example#0-pre-requisites-before-you-start)

On your `localhost`, 
run the following commands 
in your terminal:

```sh
git clone git@github.com:dwyl/app-mvp.git && cd app-mvp
source .env_sample
mix setup
```
That will load up the necessary env variables to run the app, 
download the **`code`**, 
install dependencies,
and create the necessary database + tables.

The line 
`source .env_sample` 
loads the 
[environment variables](https://github.com/dwyl/learn-environment-variables)
required to run the App.



<!--
If for any reason you have an error while running the setup, try to rebuild/compile
the application by deleting the existing `_build` folder and running the `setup` again:

```sh
rm -r _build
mix setup
```


## _Single_ Environment Variable: `AUTH_API_KEY`

Follow the instructions in **Step 2** of
[**`auth_plug`**](https://github.com/dwyl/auth_plug#2-get-your-auth_api_key-)
to create your 
**`AUTH_API_KEY`**.

-->

Once the `mix setup` command completes,
you can run the app with:

```sh
mix s
```

Open the App in your web browser
[**`localhost:4000`**](http://localhost:4000/)
and start your tour! 

<br />

## _Build_ It! 👷‍♀️

If you want to understand how to _build_ the MVP,
please see:
[**`BUILDIT.md`**](https://github.com/dwyl/app-mvp/blob/main/BUILDIT.md)

<br />


## Contributing 👩‍💻

All contributions 
from typo fixes
to feature requests
are always welcome! 🙌

Please start by: <br />
a. **Star** the repo on GitHub 
  so you have a "bookmark" you can return to. ⭐ <br />
b. **Fork** the repo 
  so you have a copy you can "hack" on. 🍴 <br />
c. **Clone** the repo to your `localhost` 
  and run it! (see below) 👩‍💻 <br />


For more detail,
please see:
[dwyl/**contributing**](https://github.com/dwyl/contributing)

### More Features? 🔔

Please note that our goal with this MVP
is _not_ to have _all_ the features; 
again, it's _deliberately_  simple.<br />
We will be adding _lots_ more features
to the _full_
[**App**](https://github.com/dwyl/app). <br />
If you have feature ideas, that's great! 🎉 <br />
Please _share_ them: 
[**app/issues**](https://github.com/dwyl/app/issues)

