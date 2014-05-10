#!/bin/bash
BASEPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$BASEPATH/duckdns.cfg"

[ -z $NO_CERT] && NO_CERT=0
[ -z $MAXRETRIES ] && MAXRETRIES=0

DOMAINS=${DOMAINS//[[:space:]]/}
[ -z $DOMAINS ] && log "DOMAINS is Blank" && exit 1

TOKEN=${TOKEN//[[:space:]]/}
[ -z $TOKEN ] && log "TOKEN is Blank" && exit 1

LASTFILE="$BASEPATH/lastip"

# Additional methods names added to this array will get randomly chosen
METHODS=("http_method" "http_method" "http_method" "dig_method" "dyndns_method" "ipapi_method")
# Additional hostnames added to this array will get randomly chosen in the http_method
HTTP_SERVICES=( \
    "ifconfig.me/ip" "ipecho.net/plain" "ipv4.icanhazip.com" "curlmyip.com" \
    "v4.ident.me" "ipinfo.io/ip" "bot.whatismyipaddress.com" "ip4.telize.com")

log () {
    NOW=$(date +"%x %X")
    echo "[$NOW] $1"
}

set_http_fetch () {
    local com_str
    com_str=$(command -v curl)
    if [ $? -eq 0 ]; then
        com_str="$com_str -s"
        [ "$NO_CERT" -eq 1 ] && com_str="$com_str -k"
    else 
        com_str=$(command -v wget)
        if [ $? -eq 0 ]; then
            com_str="$com_str -q -O -"
            [ "$NO_CERT" -eq 1 ] && com_str="$com_str --no-check-certificate"
        else
            log "No HTTP Fetch program found. Install curl or wget"
            exit 1
        fi
    fi

    echo "$com_str"
}

# Each IP detection method should echo the current IP Address as output
http_method () {
    local pick=$(( $RANDOM % ${#HTTP_SERVICES[@]} ))
    $HTTP_FETCH "${HTTP_SERVICES[$pick]}"
    return $pick
}

dig_method () {
    dig +short myip.opendns.com @resolver1.opendns.com
}

dyndns_method () {
    $HTTP_FETCH "checkip.dyndns.org" | sed -n 's/.*IP Address: \([[:digit:]\.]\+\).*/\1/p'
}

ipapi_method () {
    $HTTP_FETCH "http://ip-api.com/line" | tail -1
}

HTTP_FETCH=$(set_http_fetch)

LASTIP=""
[ -f "$LASTFILE" ] && LASTIP=$(cat "$LASTFILE")

IP=""
try=1
while [ "$IP" == "" ]; do
    PICK=$(( $RANDOM % ${#METHODS[@]} ))
    IP=$(${METHODS[$PICK]})
    curl_pick=$?

    message="Try #$try: Got $IP from ${METHODS[$PICK]}"
    if [ "${METHODS[$PICK]}" == "http_method" ]; then
        message="$message (${HTTP_SERVICES[$curl_pick]})"
    fi

    log "$message"

    if [ "$try" -gt "$MAXRETRIES" ]; then
        # Unable to get a good response, try to update dns anyway
        break
    fi
    (( ++try ))
done

if [ "$LASTIP" != "$IP" ]; then
    log "Updating IP to $IP"
    url="https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&ip=" 
    response=$($HTTP_FETCH "$url")
    log "$response"
    echo "$IP" > "$LASTFILE"
else
    log "IP Unchanged. Skipping Update."
fi
