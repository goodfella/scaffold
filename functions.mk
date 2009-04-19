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


# takes in a list of object file paths and redirects them to there
# respective obj_dir path if obj_dir is defined.

# 1 = list of object file paths
define obj_path
$(if $(obj_dir),$(foreach obj,$(1),$(addsuffix $(notdir $(obj)),$(addsuffix $(obj_dir)/,$(dir $(obj))))), \
                $(1))
endef


# takes a list of object file paths and outputs the path based on the
# obj_dir variable

# 1 = list of object file paths
define obj_dirpath
$(if $(obj_dir),$(addsuffix $(obj_dir)/,$(dir $(1))),\
                $(dir $(1)))
endef


# takes in an object file path and outputs the source file path

# 1 = object file path
# 2 = source file suffix
define obj_src
$(if $(obj_dir),$(patsubst %.$(cxx_prog_obj),%.$2,$(subst $(obj_dir)/,,$1)),\
                $(patsubst %$(cxx_prog_obj),%.$2,$1))
endef