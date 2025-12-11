#! /bin/bash
REPO=$(awk -F= '$1 == "REPO" {print $2}' .env)
OWNER=$(awk -F= '$1 == "OWNER" {print $2}' .env)
GITHUB_URL=$(printf 'https://github.com/%s/%s.git' $OWNER $REPO)

python check_change.py
CHANGE=$(echo $?)
echo $GITHUB_URL

if [ -d $REPO ]; then
    if [ $CHANGE -ne 0 ]
    then
        printf 'entering into %s\n' $REPO
        cd $REPO
        echo 'pulling from remote branch'
        git pull
    fi
else
    printf '%s not cloned. clonning from github\n' $REPO
    git clone $GITHUB_URL
fi