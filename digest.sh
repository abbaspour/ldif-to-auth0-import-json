#!/usr/bin/env bash
set -euo pipefail

declare salt=''
declare password=''
declare algorithm='sha512'
declare delimiter=''

function usage() {
    cat <<END >&2
USAGE: $0 [-p password] [-s salt] [-a algorithm] [-f users.file] [-v|-h]
        -p password  # password
        -s salt      # salt
        -a algorithm # sha1, sha256, sha512, md5, etc
        -d delimiter # delimiter (defaults empty)
        -S           # random salt
        -h|?         # usage
        -v           # verbose

eg,
     $0 -p hard-pass -s random -a sha1
END
    exit $1
}

while getopts "p:s:a:d:Shv?" opt; do
    case ${opt} in
        p) password="${OPTARG}";;
        s) salt="${OPTARG}";;
        a) algorithm="${OPTARG}";;
        d) delimiter="${OPTARG}";;
        S) salt=$(pwgen 8 -1);;
        v) set -x;;
        h|?) usage 0;;
        *) usage 1;;
    esac
done

[[ -z "${password}" ]] && { echo >&2 "ERROR: password undefined."; usage 1; }

# readonly digest=$(/bin/echo -n "${salt}${password}" | openssl ${algorithm})
readonly digest=$(/bin/echo -n "${salt}${password}" | openssl dgst -${algorithm} -binary | openssl enc -A -base64)

echo "${salt}${delimiter}${digest}"