#!/bin/bash
# vim:ts=4:sw=4:et:ai:tw=80

# A next-generation zfs-auto-snapshot. The old one relies on recursive
# snapshots, which may be a good idea performance-wise, but removes a lot of
# options for independant datasets, as in how many snapshots to keep, how often
# to snapshot, how to find empty snaps and refuse to snapshot those etc.
#
# This is an attempt to create such a thing.
#
# Licensed under GPLv2 - google for it
#
# Roy Sigurd Karlsbakk <roy@karlsbakk.net>
#
# Please note that this is not stable (or useful) so far. Hopefully this'll
# change over the next days or weeks.
#
# Some code (or a lot?) has been borrowed from the old project. The former
# version's comments are copied below
#
## zfs-auto-snapshot for Linux
## Automatically create, rotate, and destroy periodic ZFS snapshots.
## Copyright 2011 Darik Horn <dajhorn@vanadac.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, write to the Free Software Foundation, Inc., 59 Temple
## Place, Suite 330, Boston, MA  02111-1307  USA
#

# Set the field separator to a literal tab and newline.
IFS="	
"

# Set default program options.
opt_backup_full=''
opt_backup_incremental=''
opt_default_exclude=''
opt_dry_run=''
opt_event='-'
opt_fast_zfs_list=''
opt_keep=''
opt_label=''
opt_prefix='zfs-auto-snap'
opt_recursive=''
opt_sep='_'
opt_setauto=''
opt_syslog=''
opt_skip_scrub=''
opt_verbose=''
opt_pre_snapshot=''
opt_post_snapshot=''
opt_do_snapshots=1
opt_min_size=0

# Global summary statistics.
DESTRUCTION_COUNT='0'
SNAPSHOT_COUNT='0'
WARNING_COUNT='0'

# Other global variables.
SNAPSHOTS_OLD=''


print_usage ()
{
	echo "Usage: $0 [options] [-l label] <'//' | name [name...]>
  --default-exclude  Exclude datasets if com.sun:auto-snapshot is unset.
  -d, --debug        Print debugging messages.
  -e, --event=EVENT  Set the com.sun:auto-snapshot-desc property to EVENT.
      --fast         Use a faster zfs list invocation.
  -n, --dry-run      Print actions without actually doing anything.
  -s, --skip-scrub   Do not snapshot filesystems in scrubbing pools.
  -h, --help         Print this usage message.
  -k, --keep=NUM     Keep NUM recent snapshots and destroy older snapshots.
  -l, --label=LAB    LAB is usually 'hourly', 'daily', or 'monthly'.
  -p, --prefix=PRE   PRE is 'zfs-auto-snap' by default.
  -m, --min-size=n   Require at least n kB written to snapshot.
  -q, --quiet        Suppress warnings and notices at the console.
      --send-full=F  Send zfs full backup. Unimplemented.
      --send-incr=F  Send zfs incremental backup. Unimplemented.
      --sep=CHAR     Use CHAR to separate date stamps in snapshot names.
  -g, --syslog       Write messages into the system log.
  -r, --recursive    Snapshot named filesystem and all descendants.
  -v, --verbose      Print info messages.
      --destroy-only Only destroy older snapshots, do not create new ones.
      name           Filesystem and volume names, or '//' for all ZFS datasets.
" 
}


print_log () # level, message, ...
{
	LEVEL=$1
	shift 1

	case $LEVEL in
		(eme*)
			test -n "$opt_syslog" && logger -t "$opt_prefix" -p daemon.emerge $*
			echo Emergency: $* 1>&2
			;;
		(ale*)
			test -n "$opt_syslog" && logger -t "$opt_prefix" -p daemon.alert $*
			echo Alert: $* 1>&2
			;;
		(cri*)
			test -n "$opt_syslog" && logger -t "$opt_prefix" -p daemon.crit $*
			echo Critical: $* 1>&2
			;;
		(err*)
			test -n "$opt_syslog" && logger -t "$opt_prefix" -p daemon.err $*
			echo Error: $* 1>&2
			;;
		(war*)
			test -n "$opt_syslog" && logger -t "$opt_prefix" -p daemon.warning $*
			test -z "$opt_quiet" && echo Warning: $* 1>&2
			;;
		(not*)
			test -n "$opt_syslog" && logger -t "$opt_prefix" -p daemon.notice $*
			test -z "$opt_quiet" && echo $*
			;;
		(inf*)
			# test -n "$opt_syslog" && logger -t "$opt_prefix" -p daemon.info $*
			test -n "$opt_verbose" && echo $*
			;;
		(deb*)
			# test -n "$opt_syslog" && logger -t "$opt_prefix" -p daemon.debug $*
			test -n "$opt_debug" && echo Debug: $*
			;;
		(*)
			test -n "$opt_syslog" && logger -t "$opt_prefix" $*
			echo $* 1>&2
			;;
	esac
}


do_run () # [argv]
{
	if [ -n "$opt_dry_run" ]
	then
		echo $*
		RC="$?"
	else
		eval $*
		RC="$?"
		if [ "$RC" -eq '0' ]
		then
			print_log debug "$*"
		else
			print_log warning "$* returned $RC"
		fi
	fi
	return "$RC"
}

for snap in $( zfs list -t snapshot )
do

done
