# Fly Review Apps with Github Actions

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
    runs_on: ubuntu-latest
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


