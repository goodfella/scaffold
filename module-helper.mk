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


# creates the variable that stores the value of a attribute for a list
# of sources

# 1 = list of sources
# 2 = attribute
# 3 = attribute values
define create_src_var
$(foreach src,$1,$(if $3,$(eval $(src)_$(2)+=$3)))
endef

# clears out the local module variables
define reset_module_vars

local_cxx_progs :=
local_cxx_shlibs :=
local_srcs :=
local_plugs :=

endef
