#!/usr/bin/env bash

set -ueo pipefail
readonly DIR=$(dirname "${BASH_SOURCE[0]}")

function usage() {
    cat <<END >&2
USAGE: $0 [-i input.ldif] [-m map.file] [-o output.json] [-v|-h]
        -m map         # map file (default is map.json)
        -i file        # input file (LDIF)
        -o output      # output file prefix
        -s size        # approximate output file size in kb. default is 500
        -p             # pretty print
        -P             # show progress
        -h|?           # usage
        -v             # verbose

eg,
     $0 -i sample.ldif -m redhat-ds -o output -s 2048
END
    exit ${1}
}

declare input=''
declare output=''
declare space=''
declare ext_args=''
declare -i size=500
declare map="${DIR}/map"

while getopts "i:m:s:o:pPhv?" opt
do
    case ${opt} in
        i) input="${OPTARG}";;
        o) output=${OPTARG};;
        s) size=${OPTARG};;
        m) map=$(echo "${OPTARG}" | awk -F'.' '{print $1}');;
        p) space='  ';;
        P) ext_args='--progress .';;
        v) set -x;;
        h|?) usage 0;;
        *) usage 1;;
    esac
done

[[ -z "${input}" ]] && { echo >&2 "ERROR: input undefined"; usage 1; }
[[ -z "${output}" ]] && { echo >&2 "ERROR: output undefined"; usage 1; }

[[ ! -d "${DIR}/node_modules" ]] && npm i
node "${DIR}/index.js" --input "${input}" --map "${map}" --space "${space}" --size "${size}" --output "${output}" ${ext_args}