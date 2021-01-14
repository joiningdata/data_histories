#!/bin/bash
#
# USAGE: reconstruct.sh YYYY-MM-DD sets/subset.txt
#
# ex: reconstruct.sh 20190828 sets/Homo_sapiens.txt |gzip > Homo_sapiens.gene_info.gz
#
if [[ ! "$1" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
	echo USAGE: reconstruct.sh YYYY-MM-DD sets/subset.txt >&2
	echo >&2
	echo ERROR date "$1" invalid - must be like YYYY-MM-DD >&2
	exit 1
fi

if [[ ! -f "$2" ]]; then
	echo USAGE: reconstruct.sh YYYY-MM-DD sets/subset.txt >&2
	echo >&2
	echo ERROR subset file source "$2" does not exist>&2
	echo Here are your options:>&2
	find sets/ -type f >&2
	exit 1
fi

# check out the best dataset for the requested date
echo Checking out best data for "${1}..." >&2
git checkout --quiet `git rev-list -1 --before="${1}T23:59:59" main`

#dump the header and all of the files in the subset
echo Reconstructing file... >&2
cat gene_info.header.txt
awk '/^[0-9]/ {print "genes_" int($1/1000) "k/gene_info." $1 ".txt"}' $2 | xargs cat

