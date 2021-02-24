#!/usr/bin/env bash

set -ueo pipefail
readonly DIR=$(dirname "${BASH_SOURCE[0]}")

function usage() {
    cat <<END >&2
USAGE: $0 [-i input.ldif] [-m map.file] [-o output.json] [-v|-h]
        -d domain      # Auth0 domain
        -m map         # map file (default is map.json)
        -i file        # input file (LDIF)
        -o output      # optional output file. defaults to stdout
        -p             # pretty print
        -h|?           # usage
        -v             # verbose

eg,
     $0 -i sample.ldif -o sample.json
END
    exit ${1}
}

declare input=''
declare output=''
declare space=''
declare map="${DIR}/map.json"


while getopts "i:o:phv?" opt
do
    case ${opt} in
        i) input="${OPTARG}";;
        o) output=${OPTARG};;
        p) space='  ';;
        v) set -x;;
        h|?) usage 0;;
        *) usage 1;;
    esac
done

[[ -z "${input}" ]] && { echo >&2 "ERROR: input undefined"; usage 1; }
readonly out=${output:-/dev/stdout}

[[ ! -d "${DIR}/node_modules" ]] && npm i
node "${DIR}/index.js" --input "${input}" --map "${map}" --space "${space}" > "${out}"