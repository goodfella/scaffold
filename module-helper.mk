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


# converts the extension of a file

# 1 = files
# 2 = new extension
define change_ext
$(foreach src,$1,$(patsubst %$(suffix $(src)),%.$2,$(src)))
endef


# converts the source suffix to the object file suffix

# 1 = file
# 2 = object extension
define src_obj
$(call change_ext,$1,$2)
endef


# creates the variable that stores the value of a attribute for a list
# of sources

# 1 = list of sources
# 2 = attribute
# 3 = attribute values
define create_src_var
$(foreach src,$1,$(if $3,$(eval $(call relpath,$(src))_$(2)+=$3)))
endef


# generates the object depends string

# 1 = target
# 2 = object file suffix
define obj_depends
$(call obj_path,$(call relpath,$(call src_obj,$(call srcs,$1),$2)))
endef
