# Copyright (C) 2009 Nicholas Guiffrida

# functions that are used throughout the build system

# creates a list of -I includes from a list of directories

# 1 = list of directories containing include files
define inc_dirs
$(foreach inc,$1,-I$(inc))
endef


# creates a list of -L library directories from a list of directories

# 1 = list of directories containing libraries
define lib_dirs
$(foreach lib,$1,-L$(lib))
endef


# creates a list of -l libraries to link with from a list of libraries

# 1 = list of libraries to link against
define link_libs
$(foreach lib,$1,-l$(lib))
endef

# returns the string for linker options i.e. -Wl,<options>.  If an
# empty string is given, then an empty string is returned

# 1 = possible linker options
define link_opts_string
$(if $(1),-Wl$(,)$1,)
endef