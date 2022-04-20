#!/usr/bin/env bash

set -ueo pipefail
readonly DIR=$(dirname "${BASH_SOURCE[0]}")

declare prefix='users'

function usage() {
    cat <<END >&2
USAGE: $0 [-i input.ldif] [-m map.file] [-o folder] [-p users] [-v|-h]
        -m map         # map file (default is map.json)
        -i file        # input file (LDIF)
        -o output      # output folder (default is cwd)
        -s size        # approximate output file size in kb. default is 500
        -n prefix      # output files name. default ${prefix}
        -S index       # start index. default is 0
        -p             # pretty print
        -P             # show progress
        -h|?           # usage
        -v             # verbose

eg,
     $0 -i sample.ldif -m redhat-ds -o output -p -P -n mydata -s 2048
END
    exit ${1}
}

declare input=''
declare output="${DIR}"
declare space=''
declare ext_args=''
declare -i size=500
declare -i index=0
declare map="${DIR}/map"

while getopts "i:m:s:o:n:S:pPhv?" opt
do
    case ${opt} in
        i) input="${OPTARG}";;
        o) output="${OPTARG}";;
        s) size=${OPTARG};;
        m) map="${OPTARG}";;
        n) prefix="${OPTARG}";;
        S) index="${OPTARG}";;
        p) space='  ';;
        P) ext_args='--progress .';;
        v) set -x;;
        h|?) usage 0;;
        *) usage 1;;
    esac
done

[[ -z "${input}" ]] && { echo >&2 "ERROR: input undefined"; usage 1; }
[[ -z "${output}" ]] && { echo >&2 "ERROR: output undefined"; usage 1; }
[[ -z "${map}" ]] && { echo >&2 "ERROR: map undefined"; usage 1; }

[[ ! -f "${map}" ]] && { echo >&2 "ERROR: map is not a file: ${map}"; usage 1; }
[[ ! -f "${input}" ]] && { echo >&2 "ERROR: input is not a file: ${input}"; usage 1; }
[[ ! -d "${output}" ]] && { echo >&2 "ERROR: output is not a folder: ${output}"; usage 1; }

[[ ! -d "${DIR}/node_modules" ]] && npm i
node "${DIR}/index.js" --input "${input}" --map "${map}" --space "${space}" --size "${size}" --output "${output}" --prefix "${prefix}" --index "${index}" ${ext_args}
