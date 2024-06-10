#!/bin/bash


blue="\e[0;94m"
expand_bg="\e[K"
red_bg="\e[0;101m${expand_bg}"
bold="\e[1m"
uline="\e[4m"
reset="\e[0m"

per_page=30

set -eou pipefail
cd "$(dirname "$0")"
user="${1:-Abzwingten}"
echo -e "${red_bg}${reset}"
echo -e "${blue}Welcome to github stars downloader!${reset}"
pages=$(curl -s -I https://api.github.com/users/$user/starred | sed -nr 's/^Link:.*page=([0-9]+).*/\1/p')
repolist_appr=$(expr $per_page \* $pages)
echo -e "${blue}${bold}${uline} $pages ${reset} pages of repos about to be synced"
echo -e "starting download"
cloned=0
pulled=0
for page in $(seq 1 $pages); do
    curl -s "https://api.github.com/users/$user/starred?page=$page&per_page=$per_page" |   jq -r '.[].html_url' | \
        while read rp; do
                rp_name=${rp##*/}
               # echo "URL: $rp"
                if [ ! -d "$rp_name" ]; then
                        git clone --quiet $rp
                        cloned=$((cloned+1))
                        echo "$rp_name cloned"
                else
                        cd $rp_name
                        git pull --quiet
                        pulled=$((pulled+1))
                        echo "$rp_name updated"
                fi
        done
done
echo "Cloned ${bold} $cloned ${reset} repos"
echo "Pulled ${bold} $pulled ${reset} repos"
echo -e "${red_bg}${reset}"
echo -e "${blue}DONE!${reset}"
