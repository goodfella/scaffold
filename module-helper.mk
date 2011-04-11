# Copyright (C) 2009 Nicholas Guiffrida

# functions used in all modules.mk's

# directory the module is in
module_dir = $(dir $(lastword $(MAKEFILE_LIST)))


# path relative to the top level Makefile
# usage
# 1 = filenames
define relpath
$(addprefix $(module_dir),$1)
endef

# appends object and dependency files to the object_files and
# dependencies variables

# 1 = object files
define add_object_files
object_files += $1
dependencies += $(addsuffix $(depends_file_suffix), $1)
endef

# appends the list of sources to the sources variable

# 1 = source files
define add_source_files
sources += $1
endef


# clears out the local module variables
define reset_module_vars

local_cxx_progs :=
local_cxx_shlibs :=
local_srcs :=
local_plugs :=

endef
