#!/bin/bash
username=$1
if [ -z "$username" ]; then
    read -r -p "Enter GitHub Username: " username
fi
echo "Getting Repos from $username ..."

private=0
get_private="n"

# read -r -p "Need to get private repos(y/n) [n]?" get_private
# TODO: Uncomment the above line if you want to prompt for private repo access

if [[ "$get_private" == "y" || "$get_private" == "Y" ]]; then
    private=1
    read -r -p "Enter GitHub Personal Access Token: " token
    json=$(curl -s -H "Authorization: Bearer $token" "https://api.github.com/user/repos?visibility=all&affiliation=owner")
else
    json=$(curl -s "https://api.github.com/users/${username}/repos")
fi

check_error() {
    if echo "$1" | grep -q '"Not Found"'; then
        echo "User not found"
        return 1
    fi
    if [ "$(echo "$1" | jq length)" -eq 0 ]; then
        echo "No repos found"
        return 1
    fi
    if [ -z "$1" ]; then
        echo "No Repos found or unable to fetch repos."
        return 1
    fi
    return 0
}

if ! check_error "$json"; then
    exit 1
fi

repo_names=($(echo "$json" | jq -r '.[].name'))
repo_urls=($(echo "$json" | jq -r '.[].clone_url'))

i=1
for name in "${repo_names[@]}"; do
    echo "$i $name"
    i=$((i+1))
done

BYellow=$'\033[1;33m'      # Yellow (bright yellow)
Color_Off=$'\033[0m'      # Text Reset
BGreen=$'\033[1;32m'       # Green
BRed=$'\033[1;31m'         # Red
echo "${BYellow} Options: "
echo  "1. Select repos that you ${BGreen}want to Clone${BYellow}"
echo  "2. Select repos that you ${BRed} don't want to Clone${BYellow}"
echo  "3. Clone all repos"
read -r -p"Choose (1/2/3) [default=3] ${Color_Off}" OPTION

OPTION=${OPTION:-3}
if [[ "$OPTION" == "1" || "$OPTION" == "2" ]]; then
    i=1
    for name in "${repo_names[@]}"; do
        echo "$i $name"
        i=$((i+1))
    done
    if [[ "$OPTION" == "1" ]]; then
        echo "Enter item numbers to be ${BGreen}cloned${Color_Off} (space-separated):"
    else
        echo "Enter item numbers to be ${BRed}excluded${Color_Off} (space-separated):"
    fi
    read -r -a list
fi

c=1
for url in "${repo_urls[@]}"; do
    if [[ "$OPTION" == "3" ]]; then
        skip=false
    else
        if [[ "$OPTION" == "1" ]]; then
            skip=true
        else
            skip=false
        fi
        for ex in "${list[@]}"; do
            if [[ "$c" == "$ex" ]]; then
                if [[ "$OPTION" == "2" ]]; then
                    skip=true
                else
                    skip=false
                fi
                break
            fi
        done
    fi
    k=$((c-1))
    if $skip; then
        echo "Skipped" "${BYellow}${repo_names[$k]}${Color_Off}"
    else
        echo "${BGreen}Cloning ..." "${repo_names[$k]}${Color_Off}"
        git clone "$url"
    fi
    ((c++))
done
