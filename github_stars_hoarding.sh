#!/bin/bash

cd "$(dirname "$0")"
user="$1"
#user="Abzwingten"
pages=$(curl -I https://api.github.com/users/$user/starred | sed -nr 's/^Link:.*page=([0-9]+).*/\1/p')
echo $pages
cloned=0
pulled=0
for page in $(seq 1 $pages); do
    curl "https://api.github.com/users/$user/starred?page=$page&per_page=30" |   jq -r '.[].html_url' ||  echo "ERROR OCCURED"; break
        while read rp; do
                rp_name=${rp##*/}
                echo $rp 
                echo "cloning $rp_name"
                if [ ! -d "$rp_name" ]; then
                        git clone $rp
                        cloned=$((cloned+1))
                        echo "$rp_name cloned"
                else
                        cd $rp_name
                        git pull
                        pulled=$((pulled+1))
                        echo "$rp_name updated"
                fi
        done
done
echo "Cloned $cloned repos"
echo "Pulled $pulled repos"
