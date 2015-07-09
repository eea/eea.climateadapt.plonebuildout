#!/bin/bash

LASTCFG=''

if [ -s ".mr.developer.cfg" ]; then
    LASTCFG=`sed -n "/\[buildout\]/ {N; /\.*args\ =/ {N; /\n.*-c/ {n; p;}}}" .mr.developer.cfg | sed -e 's/^[ \t]*//' | sed "s/'//g"`
fi

rm -rf ./bin ./develop-eggs ./include ./lib ./parts ./.installed.cfg

echo "$LASTCFG"

if [ -n "$LASTCFG" ]; then
    if [ -s "$LASTCFG" ]; then
        echo ""
        echo "Last buildout configuration used was: $LASTCFG. Using the same config file for reinstallation"
        echo ""
    fi
fi

./install.sh $LASTCFG
