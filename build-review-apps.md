# Fly Review Apps with Github Actions

In this small guide, 
we are going to be setting up
[CI/CD](https://aws.amazon.com/devops/continuous-integration/)
so code tests are automatically executed in every PR made to the main branch
and to maintain code quality 
throughout the development cycle.

We are going to be focusing
on the job that **deploys the app to `fly.io`**,
which constitutes the **"Review App"**.

- [Fly Review Apps with Github Actions](#fly-review-apps-with-github-actions)
  - [Setup](#setup)
  - [Workflow](#workflow)
  - [Create script](#create-script)
  - [You're done! 🎉](#youre-done-)


## Setup

Firstly,
read [Understanding Github Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions)
to have a better understanding of what Github Actions are
and how to properly have them executed.

Now we can start building our own Github actions 
that create **"Review Apps"** when a PR is created.
**"Review Apps"** pertain to the code of the PR
that is deployed automatically to 
[`fly.io`](https://fly.io/).
With this app deployed, 
it is easy to see how different the app is
with the changes made in the PR
*and* is extremely useful to also run API definition tests against it.

Because we are going to use `flyctl` to create and deploy the applications
based on the PRs, 
we first need to create a `fly auth token`.

Run `flyctl auth token`. 
This will create and show the token in your terminal.
see: https://fly.io/docs/flyctl/auth-token/.

In your Github repository, create a new secret named `FLY_API_TOKEN`
and associate to it the token: 
go to `Settings` then `Secrets` and finally `Actions`.
At the top right corner you should see the `New repository secret` button.

<img width="1138" alt="secret" src="https://user-images.githubusercontent.com/17494745/221608821-880580f2-6fb0-4aee-9735-1c44253e3ef2.png">


`flyctl` will check if the `FLY_API_TOKEN` environment variable is defined, 
and use it to manage the Fly applications.

## Workflow

If you open the file
[`.github/workflows/PR_ci.yml`](./.github/workflows/PR_ci.yml),
you will see how the "Review App" is deployed.
This file is executed on all the PRs
that target the `main` branch.

```yml
name: PR CI

on:
  pull_request:
    branches: [ main ]
    types: [opened, reopened, synchronize, closed]

jobs:

  ...

  # DEPLOY THE REVIEW APP
  # This will deploy an app to fly.io with the name 'mvp-pr-$PR_NUMBER' (check `review-apps.sh` script).
  review_app:

    # Only run when it's not a dependabot PR
    if: github.event.pull_request.user.login != 'dependabot[bot]'

    name: Review App Job
    runs-on: ubuntu-latest
    needs: [build]
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Install flyctl
        run: curl -L https://fly.io/install.sh | FLYCTL_INSTALL=/usr/local sh

      - name: Set up Elixir
        uses: erlef/setup-beam@v1
        with:
          otp-version: 24.3.4
          elixir-version: 1.14.1

      - name: Run Review App Script
        run: ./.github/scripts/review-apps.sh
        env:
          ENCRYPTION_KEYS: ${{ secrets. ENCRYPTION_KEYS }}
          AUTH_API_KEY: ${{ secrets.FLY_AUTH_API_KEY }}
          PR_NUMBER: ${{ github.event.number}}
          EVENT_ACTION: ${{ github.event.action }}
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
          FLY_ORG: dwyl-mvp
          FLY_REGION: lhr
          FLY_POSTGRES_NAME: mvp-db

      ...
```

- The Github Action is triggered when a PR is created, updated, reopened or closed:

```yml
on:
  pull_request:
    branches: [ main ]
    types: [opened, reopened, synchronize, closed]
```

- The environment variable is added to the workflow. 
The `FLY_API_TOKEN` is set
from the Github repository secrets. 
This environment is used by `flyctl` to 
authenticate the requests to Fly.io.

Learn more about Github action environment variables:
https://docs.github.com/en/actions/learn-github-actions/environment-variables

```yml
env:
  FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

- Start a new `job` with a runner based on the latest ubuntu. 
The job only runs after the `build` job 
and not when the [dependabot](https://github.com/dependabot) creates a PR.

```yml
jobs:

  ...
  review_app:

    # Only run when it's not a dependabot PR
    if: github.event.pull_request.user.login != 'dependabot[bot]'

    name: Review App Job
    runs-on: ubuntu-latest
    needs: [build]
    steps:
```

- Defining the rest of the steps of the job

First,
we checkout the repository to the 
runner using the `actions/checkout`. 
This allows the runner to access the files in the repository. 
`flyctl` needs to be able to read the `Dockerfile` and the `fly.toml`
to build the application, 
but we also need our runner to be able to access
the shell script defined in the last step.

The second step is to install `flyctl`: `curl -L https://fly.io/install.sh | FLYCTL_INSTALL=/usr/local sh`
This command downloads `flyctl` and installs it in `/usr/local`. 
The `FLYCTL_INSTALL` environment variable 
is used in the `install.sh` script to define where to install `flyctl`, 
see: https://github.com/superfly/flyctl/blob/74443a0696e3c3d7d8dbbec6feded3dc928e251f/installers/install.sh#L17

> `/usr/local` is used by the system administrator when installing software locally.

The third and final step is to run the shell script 
that we're going to define next.
This script will contain all the required `flyctl` command calls 
to create and deploy our "review apps".

```yml
- name: Run Review App Script
  run: ./.github/scripts/review-app.sh
```


```yml
steps:
  - name: Checkout repository
    uses: actions/checkout@v3
  - name: Install flyctl
    run: curl -L https://fly.io/install.sh | FLYCTL_INSTALL=/usr/local sh
  - name: Run Review App Script
    run: ./.github/scripts/review-app.sh
```

ref: [Using jobs in a workflow](https://docs.github.com/en/actions/using-jobs/using-jobs-in-a-workflow)

## Create script

This script takes inspiration from: https://github.com/superfly/fly-pr-review-apps/blob/main/entrypoint.sh

The first step is to create the script file `.github/scripts/review-app.sh` and
make it executable by running `chmod +x .github/scripts/review-app.sh`

Add the following content to the file:

```sh
set -e

echo "Review App Script"
# create "unique" name for fly review app
app="mvp-pr-$PR_NUMBER"
secrets="AUTH_API_KEY=$AUTH_API_KEY ENCRYPTION_KEYS=$ENCRYPTION_KEYS"

if [ "$EVENT_ACTION" = "closed" ]; then
  flyctl apps destroy "$app" -y
  exit 0
elif ! flyctl status --app "$app"; then
  # create application
  echo "lauch application"
  flyctl launch --no-deploy --copy-config --name "$app" --region "$FLY_REGION" --org "$FLY_ORG"

  # attach existing posgres
  echo "attach postgres cluster - create new database based on app_name"
  flyctl postgres attach "$FLY_POSTGRES_NAME" -a "$app"

  # add secrets
  echo "add AUTH_API_KEY and ENCRYPTION_KEYS envs"
  echo $secrets | tr " " "\n" | flyctl secrets import --app "$app"

  # deploy
  echo "deploy application"
  flyctl deploy --app "$app" --region "$FLY_REGION" --strategy immediate

else
  echo "deploy updated application"
  flyctl deploy --app "$app" --region "$FLY_REGION" --strategy immediate
fi
```

- `set -e`:

This tells the script to stop if one of the executed command fails.
You can see the documentation with `help set`:
> -e  Exit immediately if a command exits with a non-zero status.

- Then we define a unique name for the application, and build the environment
variables we're going to add to the Fly application:

```sh
app="mvp-pr-$PR_NUMBER"
secrets="AUTH_API_KEY=$AUTH_API_KEY ENCRYPTION_KEYS=$ENCRYPTION_KEYS"
```

- When the action that trigger the Github action is due to the PR being closed
we're deleting the existing Fly review app with

```sh
flyctl apps destroy "$app" -y
```

The flag `-y` automatically confirms the deletion when asked by the flyctl command.

- If the action linked to the PR is not the "closed" one (open, reopen or synchronize),
we first check if a Fly application with the name `mvp-pr-<pr-number>` already exists.
If it doesn't, we first create the application with:

```sh
flyctl launch --no-deploy --copy-config --name "$app" --region "$FLY_REGION" --org "$FLY_ORG" --remote-only
```

- `--no-deploy `to not deploy the application yet as we need to set environment variables
and attach the database to it.

- `--copy-config`, use the existing configuration file.

See more documentation for launch: https://fly.io/docs/flyctl/launch/.

The next step is to attach the existing postgres cluster to the new application with:

```sh
flyctl postgres attach "$FLY_POSTGRES_NAME" -a "$app"
```

Then we add the environment variable with:

```sh
echo $secrets | tr " " "\n" | flyctl secrets import --app "$app"
```

The `tr` command replaces the spaces by new lines. The values are then piped
to the `flyctl secrets inport` command.


Finally we deploy the application!

```sh
flyctl deploy --app "$app" --region "$FLY_REGION" --strategy immediate
```
see deploy doc: https://fly.io/docs/flyctl/deploy/.

> `--strategy string`
The strategy for replacing running instances. 
Options are `canary`, `rolling`, bl`uegreen,
or `immediate`. 
Default is `canary`, or `rolling` when max-per-region is set.


If the application already exists we only use the `deploy` command as we don't 
need to `launch`, set environment variables or attach the Postgres cluster.


For newly created applications,
a new empty database and user for the database will be created.

When PRs are merged/closed, the Fly apps will be **destroyed**.
However, the database and user will still be present in the cluster.

To remove them, run:

```sh
flyctl postgres connect -a <postgres-cluster-name>
```

Once connected, in `psql`, run:

```sh
drop database <name-database> with (force);
drop user <name-user>;
```

## You're done! 🎉

Now you know how to create a job 
that uses a *script* to deploy 
a "Review App"!

If you take a look at the 
rest of [`.github/workflows/PR_ci.yml`](./.github/workflows/PR_ci.yml),
you will notice there are two other jobs:

- **`build`**: builds and runs the unit tests
of the Elixir app.
It also checks if code is formatted.
If executed successfully, 
the code coverage is pushed to `Codecov`.
- **`api_definition`**: runs API definition tests.
It *must be executed **after*** the `review_app` job,
because it makes requests to the deployed "Review App".





