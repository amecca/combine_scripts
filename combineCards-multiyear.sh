#!/bin/sh
set -e

. ${0%/*}/combineCards_Run2.sh --source

show_help(){ cat <<EOF
usage: ${0##*/} DIR [REGEX]

Run combineCards_Run2, which runs combineCards.py with custom names,
on the cards in DIR, optionally filtering with REGEX.
The resulting card is saved in a folder named "multiyear_<SUFFIX>",
where SUFFIX is derived by DIR.

options:
    -h      show help and exit
EOF
}

[ $# -ge 1 ] || { show_help >&2 ; exit 1 ; }
[ $1 = "-h" ] && { show_help ; exit 0 ; }

card_dir="$1"
pattern="${2:-.}"

outputdir=$(echo $card_dir | sed 's/^[^_-]\+/multiyear/')
[ -e $outputdir ] && { echo "ERROR: \"$outputdir\" already exists" >&2 ; exit 2 ; }

mkdir multiyear
strategies=$(ls "$card_dir" | grep -P "$pattern" | cut -d _ -f 2- | sed "s/.txt$//g" | sort | uniq)
for strategy in $strategies ; do
    combineCards_Run2 "${card_dir}"/{year}_${strategy}.txt || break
done
mv multiyear $outputdir

echo "INFO: output directory renamed \"$outputdir\""
