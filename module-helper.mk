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
SCAFFOLD_OBJ_FILES += $1
SCAFFOLD_DEPENDENCIES += $(addsuffix $(SCAFFOLD_DEPENDS_SUFFIX), $1)
endef

# appends the list of sources to the sources variable

# 1 = source files
define add_source_files
SCAFFOLD_SOURCES += $1
endef


# appends the library to the list of libraries

# 1 = library full path
define add_library
SCAFFOLD_LIBRARIES += $1
endef


# appends the program to the list of programs

# 1 = program full path
define add_program
SCAFFOLD_PROGRAMS += $1
endef


# adds files to clean when targets are cleaned

# 1 = path to file
define add_target_clean
SCAFFOLD_TARGET_CLEAN += $1
endef
