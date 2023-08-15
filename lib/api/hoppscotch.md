# _Advanced/Automated_ `API` Testing Using `Hoppscotch`

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

Read more about `Hoppscotch`: 
[hoppscotch.io](https://hoppscotch.io)

## `Hoppscotch` Setup

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


## Using `Hoppscotch`

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

## Integration with `Github Actions` with `Hoppscotch CLI`

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

### Changing the workflow `.yml` file

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
    - uses: actions/checkout@v3
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

### Changing the `priv/repo/seeds.exs` file

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

# Troubleshooting

If you get stuck while getting this setup,
please read through:
[dwyl/mvp/**issues/268**](https://github.com/dwyl/mvp/issues/268)
and leave a comment.
