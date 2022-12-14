# Fly Review Apps with Github Actions

## Setup

Firstly read [Understanding Github Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions).

Now we can start to build our own Github actions to create "review apps"
when a PR is created.

Because we are going to use `flyctl` to create and deploy the applications
based on the PRs, we need first to create a `fly auth token`.

Run `flyctl auth token`. This will create and show the token in your terminal.
see: https://fly.io/docs/flyctl/auth-token/

In your Github repository, create a new secret named `FLY_API_TOKEN`
and associate to it the token: go to `Settings` then `Secrets` and finally `Actions`.
At the top right corner you should see the `New repository secret` button.

`flyctl` will check if the `FLY_API_TOKEN` environment variable is defined, and
use it to manage the Fly applications.

## Create Workflow

Create a new [workflow](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions#workflows)
file, for example `.github/workflows/review-apps.yml`:

```yml
name: Review App
on:
  pull_request:
    types: [opened, reopened, synchronize, closed]
env:
  FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
jobs:
  review_app:
    name: Review App Job
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Install flyctl
        run: curl -L https://fly.io/install.sh | FLYCTL_INSTALL=/usr/local sh
      - name: Run Review App Script
        run: ./.github/scripts/review-app.sh
```

- Trigger this Github action when a PR is created, updated, reopened or closed:

```yml
on:
  pull_request:
    types: [opened, reopened, synchronize, closed]
```

- Add the environment variable to the workflow. The `FLY_API_TOKEN` is set
from the Github repository secrets. This environment is used by `flyctl` to 
authenticate the requests to Fly.io.

Learn more about Github action environment variables:
https://docs.github.com/en/actions/learn-github-actions/environment-variables

```yml
env:
  FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

- Start a new `job` with a runner based on the latest ubuntu:

```yml
jobs:
  review_app:
    name: Review App Job
    runs-on: ubuntu-latest
```

- Finally define the steps of the job.

First we checkout the repository to the 
runner using the `actions/checkout`. This allow the runner to access the files
in the repository. `flyctl` needs to be able to read the `Dockerfile` and the `fly.toml`
to build the application but we also need our runner to be able to access the shell
script defines in the last steps.

The second steps is to install `flyctl`: `curl -L https://fly.io/install.sh | FLYCTL_INSTALL=/usr/local sh`
This command download `flyctl` and install it in `/usr/local`. The `FLYCTL_INSTALL`
environment variable is used in the `install.sh` script to define where to install
`flyctl`, see:
https://github.com/superfly/flyctl/blob/74443a0696e3c3d7d8dbbec6feded3dc928e251f/installers/install.sh#L17

> /usr/local is used by the system administrator when installing software locally

The third and final step is to run the shell script that we're going to define next.
This script will contain all the required `flyctl` command calls to create and deploy
our review applications.

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

refs:
- [Using jobs in a workflow](https://docs.github.com/en/actions/using-jobs/using-jobs-in-a-workflow)

# Create script

This script take inspiration from: https://github.com/superfly/fly-pr-review-apps/blob/main/entrypoint.sh

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

--no-deploy to not deploy the application yet as we need to set environment variables
and attach the database to it.

--copy-config, use the existing configuration file.

See more documentation for launch: https://fly.io/docs/flyctl/launch/

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


Finally we deploy the application:

```sh
flyctl deploy --app "$app" --region "$FLY_REGION" --strategy immediate
```
see deploy doc: https://fly.io/docs/flyctl/deploy/

> --strategy string
The strategy for replacing running instances. Options are canary, rolling, bluegreen,
or immediate. Default is canary, or rolling when max-per-region is set.


If the application already exists we only use the `deploy` command as we don't 
need to `launch`, set environment variables or attach the postgres cluster.


For new created applications a new empty database and user for the database will
be created.

When PRs are merged/closed the Fly applications will be `destroyed`, however
the database and user will still be present in the cluster.

To remove them run:

```sh
flyctl postgres connect -a <postgres-cluster-name>
```

Once connected in psql run:

```sh
drop database <name-database> with (force);
drop user <name-user>;
```

To see existing databases and users (roles):

```sh
# \l
# \du
```

\l list the databases
\du list the users




