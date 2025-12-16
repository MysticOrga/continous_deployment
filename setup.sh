
#! /bin/bash
REPO=$(awk -F= '$1 == "REPO" {print $2}' .env)
OWNER=$(awk -F= '$1 == "OWNER" {print $2}' .env)
GITHUB_ACCESS_TOKEN=$(awk -F= '$1 == "GITHUB_ACCESS_TOKEN" {print $2}' .env)
GITHUB_URL=$(printf 'https://github.com/%s/%s.git' $OWNER $REPO)

echo "generating ssh key pair..."
if [ ! -d "./.ssh" ]; then
  mkdir ./.ssh
fi
if [ ! -s "./.ssh/deploy_key" ]; then
  ssh-keygen -t rsa -C $(printf 'deploy-key-for-%s' $REPO) -f ./.ssh/deploy_key -N ""
fi

echo "create deploy ssh key from github api"
SSH_DEPLOY_KEY_PUB=$(cat ./.ssh/deploy_key.pub)
BODY=$(printf '{
    "title": "Deploy key for %s",
    "key": "%s",
    "read_only": true
  }' $REPO "$SSH_DEPLOY_KEY_PUB")
echo $BODY

curl -X POST \
  -H "Authorization: token $GITHUB_ACCESS_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/${OWNER}/${REPO}/keys \
  -d "$BODY"

touch .last_sha.txt