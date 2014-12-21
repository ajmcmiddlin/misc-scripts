#!/usr/bin/env bash

num_old_logs=3
max_log_size_kb=1024

cd "${HOME}/log"

# Returns the name of the file for log archive n of the log file name given.
# This does not care if the file exists, just calculates the name.
# $1 => name of log file
# $2 => archive number
function get_name_of_archive_n {
	printf "%s.%d.gz" "$1" "$2"
}

# Takes a file as one and only argument and rotates it. Rotation means deleting
# the oldest archive, moving existing archives to one older, and archiving the
# previously active log.
# $1 => name of log file
function rotate {
	log_name="$1"

	# Remove the oldest one if it exists
	log_curr_name="$(get_name_of_archive_n "$log_name" "$num_old_logs")"
	[[ -e "$log_curr_name" ]] && rm -f "$log_curr_name"

	# Move remaining log archives to one older
	((log_curr_num=$num_old_logs-1))
	while (( log_curr_num > 0 )); do
		log_curr_name="$(get_name_of_archive_n "$log_name" "$log_curr_num")"
		if [[ -e "$log_curr_name" ]]; then
			log_next_name="$(get_name_of_archive_n "$log_name" $((log_curr_num+1)))"
			mv "$log_curr_name" "$log_next_name"
		fi
		((log_curr_num=log_curr_num-1))
	done

	# Move active and compress
	log_curr_name="$(get_name_of_archive_n "$log_name" 1)"
	log_name_tmp="${log_name}.tmp"
	mv "$log_name" "$log_name_tmp"
	gzip "$log_name_tmp"
	mv "${log_name_tmp}.gz" "$log_curr_name"
}

for suffix in out err; do
	# Skip this suffix if it doesn't have any files
	ls *."$suffix" >/dev/null 2>&1
	[[ $?  ]] || continue

	for file in *."$suffix"; do
		size_kb=$(du -k "$file" | awk '{print $1}')
		if (( size_kb > $max_log_size_kb )); then
			rotate "$file"
		fi
	done
done
