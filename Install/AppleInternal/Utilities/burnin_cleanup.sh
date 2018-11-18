#!/bin/sh
##############################################################################
#  Filename: burnin_cleanup.sh
# Objective: Archive burnin logs and remove state files.
#
# $Id: burnin_cleanup.sh 16699 2007-02-16 01:13:12Z bcaridad $
# Version: 0.4.0
##############################################################################

dir_prefix=/AppleInternal/Diags
log_dir=${dir_prefix}/Logs
log_archive_dir=${log_dir}/archive
purpleskank_dir=${dir_prefix}/purpleskank
tables_dir=${dir_prefix}/purpleskank/tables

date_time=`/bin/date +"%m%d%Y_%H%M%S"`

fqdir="${log_archive_dir}/${date_time}"
echo $fqdir

# exit on error
set -e

echo "mkdir -p \"$fqdir\""
mkdir -p "$fqdir"


logs=(${log_dir}/burnin_summary.plist ${log_dir}/state.plist ${log_dir}/failures.plist ${purpleskank_dir}/config.plist ${tables_dir} ${log_dir}/burnin_log.txt ${log_dir}/burnin_log.xml ${log_dir}/burnin_processlog.txt ${log_dir}/filetest.errors ${log_dir}/filetest.log)

# Move out the files into the archive directory
for file in ${logs[*]}; do
    if [ -f "$file" ]; then
		echo "cp \"$file\" \"$fqdir\""
		cp "$file" "$fqdir"
    elif [ -d "$file" ]; then
		echo "cp -R \"$file\" \"$fqdir\""
		cp -R "$file" "$fqdir"
    else
		echo "warning: $file does not exists."
    fi
done

# remove the state file
# remove the first 3 files in $logs[*]
index=0;
for files in ${logs[*]}; do
    index=$((index + 1))
    echo "index: $index: $files"
    if [ $index -gt 3 ]; then
		break
    fi
    
    if [ -f "${files}" ]; then
		echo "rm \"${files}\""
		rm "${files}"
    else
		echo "warning: state file: \"${files}\" not found"
    fi
done

# A status message for skankphone to pickup if it wants to.
echo "Cleaned up.  Ready for re-induction." > /AppleInternal/Diags/Logs/status.txt
