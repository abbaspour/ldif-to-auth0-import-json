#!/usr/bin/env bash

set -euo pipefail

declare users_file=''
declare connection_id=''

function usage() {
    cat <<END >&2
USAGE: $0 [-e env] [-a access_token] [-c connection_id] [-f users.file] [-v|-h]
        -e file     # .env file location (default cwd)
        -a token    # access_token. default from environment variable
        -c id       # connection_id
        -f file     # users file
        -i ext_id   # external job id
        -U          # disable upsert
        -h|?        # usage
        -v          # verbose

eg,
     $0 -f users.json -c con_Z1QogOOq4sGa1iR9
END
    exit $1
}

declare upsert='true'
declare external_id=''

while getopts "e:a:f:c:i:Uhv?" opt
do
    case ${opt} in
        e) source "${OPTARG}";;
        a) access_token=${OPTARG};;
        c) connection_id=${OPTARG};;
        f) users_file=${OPTARG};;
        i) external_id=${OPTARG};;
        U) upsert='false';;
        v) set -x;;
        h|?) usage 0;;
        *) usage 1;;
    esac
done

[[ -z "${access_token}" ]] && { echo >&2 "ERROR: access_token undefined. export access_token='PASTE' "; usage 1; }
[[ -z "${connection_id}" ]] && { echo >&2 "ERROR: connection_id undefined."; usage 1; }
[[ -z "${users_file}" ]] && { echo >&2 "ERROR: users_file undefined."; usage 1; }
[[ -z "${external_id}" ]] && external_id="${users_file}"

readonly AUTH0_DOMAIN_URL=$(echo "${access_token}" | awk -F. '{print $2}' | base64 -di 2>/dev/null | jq -r '.iss')

curl -s -H "Authorization: Bearer ${access_token}" \
    -F users=@"${users_file}" \
    -F connection_id="${connection_id}" \
    -F upsert=${upsert} \
    -F send_completion_email=false \
    -F external_id="${external_id}" \
    --url "${AUTH0_DOMAIN_URL}api/v2/jobs/users-imports" | jq -r '.id'

