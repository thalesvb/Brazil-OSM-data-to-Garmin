#!/bin/bash
rm *.zip *.sha512 *.exe *.img
cd ..
rm 632400* 2> /dev/null
rm brazil.osm brazil.osm.pbf 2> /dev/null
rm wget-log* 2> /dev/null
rm osmosis.log splitter.log 2> /dev/null
rm makensis.log 2>  /dev/null
echo ""
echo "Limpeza concluía."
echo ""
