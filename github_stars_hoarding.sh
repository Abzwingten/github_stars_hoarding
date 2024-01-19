#!/bin/bash

cd ../"$(dirname "$0")"
user="$1"
user="$github_username"
pages=$(curl -I https://api.github.com/users/$user/starred | sed -nr 's/^link:.*page=([0-9]+).*/\1/p')

for page in $(seq 1 $pages); do
    curl "https://api.github.com/users/$user/starred?page=$page&per_page=30" |   jq -r '.[].html_url'  | 
    while read rp; do
      if [ ! -d "$rp" ]; then
              git clone $rp
        else
                git pull $rp
        fi
    done
done
