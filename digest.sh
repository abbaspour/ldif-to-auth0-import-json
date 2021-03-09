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
        -a algorithm # sha1, sha256, ssha512
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

readonly tmp=$(mktemp)
/bin/echo -n "${password}${salt}" | openssl dgst -"${algorithm}" -binary > "${tmp}"

[[ -n "${salt}" ]] && /bin/echo -n "${salt}" >> "${tmp}"

readonly digest=$(openssl enc -in "${tmp}" -A -base64)

declare prefix=''

if [[ -n "${salt}" ]]; then
  if [[ "${algorithm}" == 'sha1' ]]; then prefix='{SSHA}'; fi
  if [[ "${algorithm}" == 'sha256' ]]; then prefix='{SSHA256}'; fi
  if [[ "${algorithm}" == 'sha512' ]]; then prefix='{SSHA512}'; fi
else
  if [[ "${algorithm}" == 'sha1' ]]; then prefix='{SHA}'; fi
  if [[ "${algorithm}" == 'sha256' ]]; then prefix='{SHA256}'; fi
  if [[ "${algorithm}" == 'sha512' ]]; then prefix='{SHA512}'; fi
fi

echo "${prefix}${digest}"