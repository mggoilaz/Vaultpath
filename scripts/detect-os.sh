#!/usr/bin/env bash
detect_os() {
    case "$(uname -s 2>/dev/null)" in
        Linux)  export OS_TYPE="linux";   export OS_NAME="Linux" ;;
        Darwin) export OS_TYPE="mac";     export OS_NAME="macOS" ;;
        MINGW*|CYGWIN*|MSYS*) export OS_TYPE="windows"; export OS_NAME="Windows" ;;
        *) [ -n "$WINDIR" ] && export OS_TYPE="windows" OS_NAME="Windows" || export OS_TYPE="unknown" OS_NAME="Unknown" ;;
    esac
    echo "$OS_NAME"
}
detect_os
