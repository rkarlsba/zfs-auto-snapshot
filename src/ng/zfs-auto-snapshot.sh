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
