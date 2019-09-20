TOKEN="" # Bot token
API="https://api.telegram.org/bot$TOKEN/"

Channel="" # Telegram channel to send messages

request() {
    local URL="$API$1"

    status=$(wget -qO- --server-response "$URL" 2>&1 | awk '/^  HTTP/{print $2}')
}

checkToken() {
    request 'getMe'
    if [ "$status" != "200" ]; then 
        echo "[ERROR] Token is invalid."
        exit 1
    fi
}

sendMessage() {
    request "sendMessage?chat_id=$1&text=$2&parse_mode=Markdown"
}

checkToken
sendMessage $Channel "$1"
