#!/bin/sh
set -e

show_help(){ cat <<EOF
Usage: ${0##*/} [-u] [-r MU] DIR [PATTERN]"
Run a likelihood scan for all the cards in DIR that match PATTERN (if specified)

    -u      unblind
    -r VAL  set the expected signal strength to VAL; ignored if -u is set
EOF
}

extrargs=""
OPTIND=1
while getopts "hur:" opt; do
    case $opt in
	h)
	    show_help
	    exit 0
	    ;;
	u)
	    extrargs="$extrargs -u"
	    ;;
	r)
	    extrargs="$extrargs -r $OPTARG"
	    ;;
	*)
	    echo "WARN: forwarding \"-$opt\" assuming it does not have an argument" >&2
	    extrargs="$extrargs -$opt"
	    ;;
    esac
done
shift "$((OPTIND-1))"

[ $# -ge 1 ] || { show_help >&2 ; exit 1 ; }
carddir=$1
pattern="${2:-.}"

cd scanl
for card in $(ls ../$carddir | grep -P "$pattern") ; do
    logfile=${card%.txt}.log
    echo "INFO: log in $logfile"
    do_scanl-groups-nodatadr.sh $extrargs ../$carddir/$card &> $logfile &
done
wait
