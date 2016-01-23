#!/bin/bash
OS=$(uname)

case "$OS" in
    'SunOS')
            AWK=/usr/bin/nawk
            ;;
    'Linux')
            AWK=/usr/bin/awk
            ;;
    'AIX')
            AWK=/usr/bin/awk
            ;;
esac

netstat -an | $AWK -v start=1 -v end=65535 ' $NF ~ /TIME_WAIT|ESTABLISHED/ && $4 !~ /127\.0\.0\.1/ {
    if ($1 ~ /\./)
            {sip=$1}
    else {sip=$4}

    if ( sip ~ /:/ )
            {d=2}
    else {d=5}

    split( sip, a, /:|\./ )

    if ( a[d] >= start && a[d] <= end ) {
            ++connections;
            }
    }
    END {print connections}'
