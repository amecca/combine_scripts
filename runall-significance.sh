#!/bin/sh

show_help(){ cat <<EOF 
Usage: ${0##*/} -u [-r VAL] DIR"

Run Significance on all the cards in CARD_DIR for the strategies of region REGION
EOF
}

print_error(){ printf "%s failed (%d).\n" "$1" $? ; exit 2 ; }

unblind=false
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
	    unblind=true
	    ;;
	*)
	    echo "Unknown option \"$opt\"" >&2
	    show_help >&2
	    exit 1
	    ;;
    esac
done
shift "$((OPTIND-1))"

[ $# -eq 1 ] || { show_help >&2 ; exit 1 ; }
carddir=$1
pattern="${2:-.}"
extraopts="-r $mu"
$unblind && extraopts="$extraopts -u"

for card in $(find $carddir -maxdepth 1 -type f -name "*.txt" | grep -P "$pattern") ; do
    strategy=$(basename ${card%.txt})
    echo "*** ${strategy} ***"
    do_significance.sh $extraopts $card || break
done
