# This script configures the application
# To remove all files but this one, run the following commands:
#   shopt -s extglob
#   rm -rvf !("agenda") .*
#   shopt -u extglob

#!/bin/bash

# Generate app skeleton
express --force --view=pug

# Create github repository
read -p "Name of app to create: " appname
curl -u 'CitedCub' https://api.github.com/user/repos -d '{"name":"'$appname'","gitignore_template":"Node"}'

# Create local git repository
git init

# Fetch all from newly created github repository
git remote add origin https://github.com/CitedCub/$appname.git
git fetch --all
git pull origin master

# Push the skeleton to the github repository
git add -A
git commit -m "Added app skeleton content"
git push origin master

# Update the app for Heroku
npm install --save-dev json
nodeversion=$(node -v | tr -d "v")
./node_modules/.bin/json -I -f package.json -e 'this.engines={"node": "'$nodeversion'"}'

# Create Heroku application
heroku create $appname
# Deploy application to Heroku
git push heroku master
# Browse to app
heroku open

# Enable development server restart on file changes
npm install --save-dev nodemon
./node_modules/.bin/json -I -f package.json -e 'this.scripts.devstart="nodemon ./bin/www"'

# Install jest (https://medium.com/@ryanblahnik/setting-up-testing-with-jest-and-node-js-b793f1b5621e)
npm install --save-dev jest

# Install mongoose
npm install --save mongoose

## Configure MongoDB Atlas
# Set organization name
orgname="DailyAppOrg"
# Set project name
projname="DailyAppProject"

# Get information about organizations
orginfo=$(curl --user "andreas.erlandsson@gmail.com:ed3fec37-5aba-4eab-ac5a-1bd860fa69a7" --digest --header "Accept: application/json" --header "Content-Type: application/json" "https://cloud.mongodb.com/api/atlas/v1.0/orgs?pretty=true")
# Get id of newly created organization
orgnumber=$(jq '.results | map(select(.name == "'"$orgname"'")) | .[0].id' <(echo $orginfo))
orgnumber=${orgnumber//\"/}

# Get information about projects
projinfo=$(curl -u "andreas.erlandsson@gmail.com:ed3fec37-5aba-4eab-ac5a-1bd860fa69a7" --digest "https://cloud.mongodb.com/api/atlas/v1.0/groups?pretty=true")
# Get id of newly created project
projnumber=$(jq '.results | map(select(.name == "'"$projname"'")) | .[0].id' <(echo $projinfo))
projnumber=${projnumber//\"/}
echo $projnumber

# Create cluster - NOT POSSIBLE for M0 free tiers (https://docs.atlas.mongodb.com/reference/free-shared-limitations/#atlas-free-tier)
# "You cannot modify or configure an M0 Free Tier cluster using the Clusters API endpoint"

# Push application to github
git add -A
git commit -m "Configured app further"
git push origin master

# Install npm packages
npm install
# Start server
processonport3000=$(lsof -t -i:3000)
if ["$processonport3000"]; then
    echo Password required to kill process running on port 3000
    sudo kill -9 $processonport3000
fi
DEBUG=$appname:* npm run devstart
