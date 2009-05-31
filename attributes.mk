# Copyright (C) 2009 Nicholas Guiffrida

# defines for attributes for the different types of objects.  Objects
# are what the build system acts on.  The object hierarchy is as
# follows (super objects are at the far left):

#compiled
#	targets
#		shared libraries
#		programs

#	sources

#not compiled

#	files


# attributes are inherited, so the valid attributes for a shared
# library are the target attributes and the compiled object
# attributes.  you specify attributes on an object in a module.mk file
# by creating a variable whose name is the object name as given in the
# module.mk file followed by a underscore '_' and the attribute name.
# The value of the variable is the value of the attribute for that
# object


# unless otherwise noted, the first argument to the function is the
# name of the object


# 1 = name of object
# 2 = name of attribute
define attribute
$($(1)_$(2))
endef

# global attributes apply to all objects


# compiled object attributes

# flags for C compiler
define ccflags
$(call attribute,$1,$0)
endef

# flags for C++ compiler
define cxxflags
$(call attribute,$1,$0)
endef

# C preprocessor flags
define cppflags
$(call attribute,$1,$0)
endef

# include directories
define incdirs
$(call attribute,$1,$0)
endef


# target attributes

# libraries that need to be built before the target that the target
# links against
define prelibs
$(call attribute,$1,$0)
endef

# linker options for gcc -rdynamic, -shared etc.
define ldflags
$(call attribute,$1,$0)
endef

# comma deliminated list of options to pass to linker
define linkopts
$(call link_opts_string,$(call attribute,$1,$0))
endef

# directories to find libraries in -L
define libdirs
$(call attribute,$1,$0)
endef

# system libraries to link against -l
define libs
$(call attribute,$1,$0)
endef

# source files for the target
define srcs
$(call attribute,$1,$0)
endef

# source cxxflags to apply to all sources specified in the srcs
# attribute
define src_cxxflags
$(call attribute,$1,$0)
endef


# source cppflags to apply to all sources specified in the srcs
# attribute
define src_cppflags
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


# resets all attributes

# 1 = object
define reset_attributes
$(1)_ccflags :=
$(1)_cxxflags :=
$(1)_cppflags :=
$(1)_incdirs :=
$(1)_ldflags :=
$(1)_prelibs :=
$(1)_linkopts :=
$(1)_libdirs :=
$(1)_libs :=
$(1)_srcs :=
$(1)_src_cxxflags :=
$(1)_src_cppflags :=
$(1)_version :=
$(1)_minor :=
$(1)_release :=
$(1)_pre_rules :=
endef
