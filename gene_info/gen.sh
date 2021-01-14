#!/bin/bash

git init .
mkdir -p sets

# create a list of all the source files, sorted by date YYYYMMDD
find . -name "*gene_info*.gz" -type f | sort -t . -k4 -n | sed 's%^./%%' > sources.txt
git add README.md sources.txt reconstruct.sh
git commit -m "beginning of data history"
git branch -M main 2>/dev/null

# enumerate the files in order, separate the components, and backdate the git commit
for fn in $(cat sources.txt); do
	echo CHECK $fn
	SETNAME=$(echo $fn | sed -r 's/^(.*)\.gene_info.*/\1/')
	if [ $SETNAME = $fn ]; then
		SETNAME=all
	fi
	gunzip -c $fn | cut -f 1 | uniq > sets/$SETNAME.txt
	cat sets/$SETNAME.txt | awk '/^[0-9]/ {system("mkdir -p genes_" int($1/1000) "k")}'

	gunzip -c $fn | head -n 100 | grep '^[^0-9]' > "gene_info.header.txt"
	gunzip -c $fn | awk -F "\t" '/^[0-9]/ {print > ("genes_" int($1/1000) "k/gene_info." $1 ".txt")}'

	# if you're using non-gnu sed (i.e. macOS) replace -r with -E here
	COMDATE=$(echo $fn | sed -r 's/.*gene_info.([0-9]{4})([0-9]{2})([0-9]{2}).gz/\1-\2-\3T12:34:56/')

	git add gene_info.header.txt */*.txt
	GIT_AUTHOR_DATE="$COMDATE" GIT_COMMITTER_DATE="$COMDATE" git commit -m "update from $fn snapshot"
done

rm -fR gene_info.header.txt genes_*k sets sources.txt
