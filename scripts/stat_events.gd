extends Node
## StatEvents provides global events for profiling and performance monitoring.
##
## It is safe to use this class in exported games, but calling the signals
## might not have an effect if objects that consume the signal calls are
## only available in editor builds.

signal viewport_activated(rid:RID)
signal viewport_deactivated(rid:RID)
