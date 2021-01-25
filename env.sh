#!/bin/bash
set -eo pipefail

# Recreate config file
if test -f ./env-config.js; then
    rm ./env-config.js
fi
touch ./env-config.js

# Add assignment
echo "window._env_ = {" >> ./env-config.js

# Read each line in .env file
# Each line represents key=value pairs
eof=
while [[ -z "$eof" ]]; do
    read -r line || eof=true   ## detect eof, but have a last round
    [[ ! ${line} ]] && continue

    # Split env variables by character `=`
    if printf '%s\n' "$line" | grep -q -e '='; then
        var_name=$(printf '%s\n' "$line" | sed -e 's/=.*//')
        var_value=$(printf '%s\n' "$line" | sed -e 's/^[^=]*=//' | sed -e 's/\r//g')
    else
        var_name=''
        var_value=''
    fi

    # Read value of current variable if exists as Environment variable
    # script should be tolerant of unbound variables
    value=$(printf '%s\n' "${!var_name}")

    # Otherwise use value from .env file
    [[ -z ${value} ]] && value=${var_value}

    # Append configuration property to JS file
    echo "${var_name}: \"${value}\"," >> ./env-config.js
done < .env

echo "}" >> ./env-config.js
