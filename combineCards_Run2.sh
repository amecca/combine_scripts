#!/bin/sh

show_help(){ cat <<EOF
usage: ${0##*/} PATTERN

Run combineCards.py on the cards using PATTERN for input selection.
PATTERN is a string containing "{year}", e.g. "mycard_{year}.txt".
The resulting card is saved in a folder named "multiyear";
the card name is derived from PATTERN by substiting "{year} -> Run2".

options:
    -h      show help and exit
EOF
}

combineCards_Run2(){
    cardpattern=$1
    outname="${cardpattern/\{year\}/Run2}"
    outname="multiyear/${outname##*/}"
    echo "INFO: output in $outname"
    combineCards.py \
	y2016preVFP="${cardpattern/\{year\}/2016preVFP}" \
	y2016postVFP="${cardpattern/\{year\}/2016postVFP}" \
	y2017="${cardpattern/\{year\}/2017}" \
	y2018="${cardpattern/\{year\}/2018}" \
	> "$outname"
}

[ "$1" = "-h" ] && { show_help ; exit 0 ; }
if ! [ "$1" = "--source" ] ; then
    [ "$#" -eq 1 ] && combineCards_Run2 $1 #|| { show_help >&2 ; exit 1 ; }
fi
