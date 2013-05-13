# Copyright (C) 2009 Nicholas Guiffrida

# defines for attributes for the different types of objects.  Objects
# are what the build system acts on.  The object hierarchy is as
# follows (super objects are at the far left):

# |-- module.mk files:
# |   \
# |    |-- attribute: module_rules
# |
# |-- buildable objects:
# |    \
# |     |-- attribute: cflags
# |     |-- object: targets (programs, libraries)
# |     |    \
# |     |     |-- attribute: set_incdirs
# |     |     |-- attribute: libdirs
# |     |     |-- attribute: shlibs
# |     |     |-- attribute: srcs
# |     |     |-- attribute: srcs_cflags
# |     |     |-- attribute: srcs_incidrs
# |     |     |-- attribute: objs
# |     |     |-- attribute: pre_rules
# |     |     |-- object: libraries (shared, static)
# |     |          \
# |     |           |-- attribute: version
# |     |           |-- attribute: minor
# |     |           |-- attribute: release
# |     |
# |     |-- object: sources
# |     |    \
# |     |     |-- attribute: incdirs

# Attributes are inherited, so the valid attributes for a shared
# library are the target attributes and the top level attributes for
# objects.

# Unless otherwise noted, the first argument to the function is the
# name of the object


# 1 = name of object
# 2 = name of attribute
define attribute
$($(1)_$(2))
endef

# Makefile where other rules are specified.  This Makefile is included
# by the build system
define module_rules
$(call attribute,$1,$0)
endef

# compiled object attributes

# flags for compiler
define cflags
$(call attribute,$1,$0)
endef

# Include directories.  These are the include directories to use for
# compiling this object.
define incdirs
$(call attribute,$1,$0)
endef

# The values of this attribute get copied to the INCDIRS variable.
define set_incdirs
$(call attribute,$1,$0)
endef

# directories to find libraries in -L
define libdirs
$(call attribute,$1,$0)
endef

# shared system libraries to link against -l
define shlibs
$(call attribute,$1,$0)
endef

# source files for the target
define srcs
$(call attribute,$1,$0)
endef

# precompiled object files for the target
define objs
$(call attribute,$1,$0)
endef

# compiler flags to apply to all sources specified in the srcs
# attribute
define srcs_cflags
$(call attribute,$1,$0)
endef

# source incdirs to apply to all sources specified in the srcs
# attribute
define srcs_incdirs
$(call attribute,$1,$0)
endef

# the following three attributes are for shared libraries and are used
# to specify the version information

# libexample.so.<version>.<minor>.<release>

# library version number
define version
$(call attribute,$1,$0)
endef

# library minor number
define minor
$(call attribute,$1,$0)
endef

# library minor number
define release
$(call attribute,$1,$0)
endef

# rule to invoke before building the target.  Note that the targets
# prerequisites are built before this rule is invoked, and also that
# each pre_rule must be unique among targets defined in the module.mk
# files
define pre_rules
$(call attribute,$1,$0)
endef
