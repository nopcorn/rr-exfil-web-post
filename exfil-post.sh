#!/bin/bash

URL="$1" 
DATA="$(echo -n '$2' | base64 -w 0)" # make sure data is a single line

# curl
if command -v curl &> /dev/null; then
    curl -X POST -H "Content-Type: application/json" -d "$DATA" "$URL"

# wget
elif command -v wget &> /dev/null; then
    wget --method=POST --header="Content-Type: application/json" --body-data="$DATA" "$URL"

# openssl (if https)
elif [[ -x "$(command -v openssl)" && "$URL" == https* ]] then
  HOST=$(echo "$URL" | awk -F/ '{print $3}')
  PATH=$(echo "$URL" | sed -e "s|https://$HOST||")
  echo -ne "POST $PATH HTTP/1.1\r\nHost: $HOST\r\nContent-Type: application/json\r\nContent-Length: ${#DATA}\r\nConnection: close\r\n\r\n$DATA" | openssl s_client -connect "$HOST:443" -quiet

# bail
else
    echo "error: needs more binaries"
fi
