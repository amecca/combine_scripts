#!/usr/bin/bash

show_help(){ cat <<EOF
usage: ${0##*/} LOGFILE [LOGFILE...]

Extract the significance of each strategy from one or more logfiles.
The name of each strategy shuld be on a line starting with "***"; the first
following line which starts with "Significance: [...]" is taken as its result.

options:
    -h      show help and exit
EOF
}

[ $# -ge 1 ] || { show_help 1>&2 ; exit 1 ; }
[ $1 = "-h" ] && { show_help ; exit 0 ; }

summary_single(){
    grep -P "^(\*{3}|Significance)" "$1" | \
	sed -e "s/ *[\*]\+ */*/g" -e "s/\*$//" -e "s/Significance: /\t/g" | \
	tr -d "\n" | \
	tr "*" "\n" | \
	sed "/^$/d"
    echo
}

# If there is only on logfile, don't bother with common name prefix and suffix
[ $# -eq 1 ] && { summary_single $1 ; exit ; }

find_prefix(){
    [ $# -lt 2 ] && return 1
    # Copied from https://stackoverflow.com/questions/6973088/longest-common-prefix-of-two-strings-in-bash
    local prefix=$(printf "%s\n%s\n" "$1" "$2" | sed -e 'N;s|^\(.*\).*\n\1.*$|\1|')
    if [ $# -eq 2 ] ; then
	# Only two arguments: we are done
	echo $prefix
    else
	# prefix (a, b, ...) = prefix(prefix(a,b), ...)
	shift 2
	find_prefix $prefix $@
    fi
}

prefix=$(find_prefix $@)
echo "Prefix: $prefix"
suffix=$(find_prefix $(echo $@ | sed "s|$prefix||g" | rev) | rev)
echo "Suffix: $suffix"

tempfiles=()
for fname in $@ ; do
    tmp=$(mktemp)
    tempfiles+=($tmp)
    summary_single $fname > $tmp
done

keys=$(cut -f 1 ${tempfiles[0]})
# keys=$(cut -f 1 $tempfiles[@] | sort | uniq)
# echo ">>> keys: $keys"

echo
{
printf "strategy"
for f in "$@" ; do
    strategyname=$(echo $f | sed "s|^$prefix||g;s|$suffix\$||g")
    [ -z $strategyname ] && strategyname="[base]"
    printf "\t%s" $strategyname
done
echo

for key in $keys ; do
    line="$key"
    # echo ">>> $key"
    for tmp in ${tempfiles[@]} ; do
	# echo -e "\t>>> $tmp"
	val=$(grep $key $tmp | cut -f 2)
	line="$line\t$val"
    done
    echo -e "$line"
done
} | column -t

for tmp in ${tempfiles[@]} ; do
    rm $tmp
done
