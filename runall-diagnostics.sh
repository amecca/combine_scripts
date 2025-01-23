#!/bin/sh
set -e
set -u

show_help(){ cat <<EOF 
Usage: ${0##*/} -u [-r VAL] DIR"
Run fit diagnostics on all the cards in DIR that match PATTERN (if specified)

    -u      unblind
    -r VAL  set the expected signal strength to VAL; ignored if -u is set
EOF
}

print_error(){ printf "%s failed (%d).\n" "$1" $? ; exit 2 ; }

unblind=0
mu=1
OPTIND=1
while getopts "hur:" opt; do
    case $opt in
	h)
	    show_help
	    exit 0
	    ;;
	r)
	    mu=$OPTARG
	    ;;
	u)
	    unblind=1
	    ;;
	*)
	    echo "Unknown option \"$opt\"" >&2
	    show_help >&2
	    exit 1
	    ;;
    esac
done
shift "$((OPTIND-1))"

[ $# -ge 1 ] || { show_help >&2 ; exit 1 ; }
carddir=$1
pattern="${2:-.}"
extraopts="-r $mu"
[ $unblind -eq 1 ] && extraopts="$extraopts -u"

mkdir -p diagnostics
cd diagnostics
for card in $(find ../$carddir -maxdepth 1 -type f -name "*.txt" | grep -P "$pattern") ; do
    logfile=$(basename ${card%.txt}.log)
    echo "INFO: log in $logfile"
    do_diagnostics.sh $extraopts $card &> $logfile &
done
wait
