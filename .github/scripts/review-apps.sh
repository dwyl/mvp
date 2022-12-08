echo "review apps script"
echo $EVENT_ACTION
echo $GITHUB_EVENT_NAME
echo $GITHUB_ACTION
echo $EVENT_NAME

# if event open or reopen
#  lauch + deploy
#
#  if event is sync
#    deploy
#
# if event is closed
#   destroy
#
# set secrets
# attach postgres
