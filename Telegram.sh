TOKEN="" # Bot token
API="https://api.telegram.org/bot$TOKEN/"

Channel="" # Telegram channel to send messages

urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
}

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
    message=$(urlencode $2)
    request "sendMessage?chat_id=$1&text=$message&parse_mode=Markdown"
}

checkToken
sendMessage $Channel "$1"
