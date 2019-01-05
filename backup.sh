#!/bin/bash

if (($# < 2)); then
	echo "Must include source and destination as first two arguments"
	exit 1
fi

src=$1
dest=$2
shift 2

extra_opts="--progress"
if (( $# == 0 )); then
	extra_opts="--dry-run -i"
elif [[ $1 != "DOIT" ]]; then
	echo "First arg must be 'DOIT' if you want me to actually copy things"
	exit 1
fi

cmd="rsync --recursive --owner --group --perms --times --copy-links --delete ${extra_opts} '$src' '$dest'"
echo "$cmd"
eval "$cmd"

exit $?
