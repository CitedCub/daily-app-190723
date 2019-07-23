#!/bin/bash
appname="SOMETHING"
curl -u 'CitedCub' https://api.github.com/user/repos -d '{"name":"'$appname'","gitignore_template":"Node"}'