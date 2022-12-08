# Fly Review Apps with Github Actions

## Setup

Firstly read [Understanding Github Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions).

Now we can start to build our own Github actions to create "review apps"
when a PR is created.

Because we are going to use `flyctl` to create and deploy the applications
based on the PRs, we need first to create a `fly auth token`.

Run `flyctl auth token`. This will create and show the token in your terminal.
see: https://fly.io/docs/flyctl/auth-token/

In your Github repository, create a new secrets named `FLY_API_TOKEN`
and associated to it the token: go to `Settings` then `Secrets` and finally `Actions`.
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
script define in the lat steps.

The second steps is to install `flyctl`: `curl -L https://fly.io/install.sh | FLYCTL_INSTALL=/usr/local sh`
This command download `flyctl` and install it in `/usr/local`. The `FLYCTL_INSTALL`
environment variable is used in the `install.sh` script to define where to install
`flyctl`, see:
https://github.com/superfly/flyctl/blob/74443a0696e3c3d7d8dbbec6feded3dc928e251f/installers/install.sh#L17

> /usr/local is used by the system administrator when installing software locally

The third and final step is to run the shell script that we're going to define next.
This script will contain all the required `flyctl` command call to create and deploy
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

Create a new shell script:

Make it executable:



