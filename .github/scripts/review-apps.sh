set -e

echo "Review App Script"
# create "unique" name for fly review app
app=$APP_NAME
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

