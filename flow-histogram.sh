#!/bin/sh

function show_help {
    (
	echo "Usage: $1 [-c PACKET_COUNT] [-n] [-f FILTER]"
	echo "Arguments:"
	echo "    -c PACKET_COUNT    Number of packets to count"
	echo "    -n                 Do not resolve addresses"
	echo "    -r                 Always try to resolve addresses"
	echo "    -f FILTER          tcpdump filter"
	echo "    -N                 Suppress tcpdump stderr"
	echo "    -Q                 Flow direction: in, out, inout (default)"
	echo "    -h                 Show this message"
    ) >/dev/$1
    exit $2
}

packet_count=1000
resolve_addrs_flag=
filter='tcp or udp'
err='/dev/stderr'
dir_arg=

while getopts c:nhrf:NQ: opt
do
    case $opt in
	c)
	    packet_count=$OPTARG
	    ;;
	n)
	    resolve_addrs_flag=-n
	    ;;
	r)
	    resolve_addrs_flag=-r
	    ;;
	f)
	    filter=$OPTARG
	    ;;
	N)
	    err='/dev/null'
	    ;;
	Q)
	    dir_arg="-Q $OPTARG"
	    ;;
	h)
	    show_help stdout 0
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    show_help stderr 2
	    ;;
    esac
done

tcpdump -c $packet_count -q -t $resolve_addrs_flag $dir_arg "${filter}" \
	2>$err \
    | awk '{
            sub(/,$/, "", $5);
            sub(/:$/, "", $4);
            print $1 " " $2 " " $4 " " tolower($5)
        }' | column -t \
    | sort | uniq -c | sort -n -r
