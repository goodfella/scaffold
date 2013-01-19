# Copyright (C) 2009 Nicholas Guiffrida

# functions used in all modules.mk's

# The path to the module file relative to SCAFFOLD_SOURCE_DIR.  All
# references to this variable must be immediately expanded.
module_dir = $(patsubst $(SCAFFOLD_SOURCE_DIR)%,%,$(dir $(lastword $(MAKEFILE_LIST))))

# module path relative to the SCAFFOLD_SOURCE_DIR usage

# 1 = filenames
define module_source_relpath
$(addprefix $(module_dir),$1)
endef


# Full path to the module's build directory.  All references to this
# variable must be immediately expanded.

# 1 = Relative path to the component
define module_build_fullpath
$(foreach path,$1,$(SCAFFOLD_BUILD_DIR)$(module_dir)$(1))
endef


# Full path to the module's source directory.  All references to this
# variable must be immediately expanded.

# 1 = Relative path to component
define module_source_fullpath
$(foreach path,$1,$(SCAFFOLD_SOURCE_DIR)$(module_dir)$(1))
endef


# Returns the precompiled module

# 1 = Path to module.mk files relative to SCAFFOLD_SOURCE_DIR
define relative_module_to_pmk
$(addsuffix $(SCAFFOLD_PMK_SUFFIX),$(basename $(addprefix $(SCAFFOLD_BUILD_DIR),$(1))))
endef



# Returns precompiled module.mk paths

# 1 = List of module.mk paths.  The paths can be relative, or full.
define precompiled_modules
$(addsuffix $(SCAFFOLD_PMK_SUFFIX),$(addprefix $(SCAFFOLD_BUILD_DIR),$(patsubst $(SCAFFOLD_SOURCE_DIR)%.mk,%,$1)))
endef


# Returns the depend files

# 1 = list of object files
define depend_files
$(addsuffix $(SCAFFOLD_DEPENDS_SUFFIX),$1)
endef

# returns an object file given a source file

# 1 = source file
# 2 = object file suffix
define obj_file
$(addprefix $(SCAFFOLD_BUILD_DIR),$(addsuffix .$(2),$(basename $(1))))
endef


# returns a list of object files given a list of full pathed source
# files

# 1 = list of source files
# 2 = object file suffix
define obj_files
$(foreach src,$(strip $(1)),$(call obj_file,$(src),$(strip $(2))))
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


# Adds files to the module's clean target

# 1 = target name
# 2 = files
define add_clean_files
$(module_dir)$(1)/clean: CLEAN_FILES += $2
endef


# Adds a target's clean rule

# 1 = target name
define add_clean_rule
.PHONY: $(module_dir)$(1)/clean
$(module_dir)clean: $(module_dir)$(1)/clean

$(module_dir)$(1)/clean:
	rm -f $$(CLEAN_FILES)
endef


# Adds a library's clean rule

# 1 = lib target name
# 2 = files
define add_lib_clean_files
$(call add_clean_files,lib-$(1),$2)
endef


# Adds a library's clean rule

# 1 = lib target name
define add_lib_clean_rule
$(call add_clean_rule,lib-$(1))
endef


# Adds the depends files for a target

# 1 = target name
# 2 = depend file paths
define add_depend_files
$(call add_clean_files,$1,$2)
SCAFFOLD_DEPENDENCIES += $2
endef


# Adds the depends files for a library target

# 1 = target name
# 2 = depend file paths
define add_lib_depend_files
$(call add_depend_files,lib-$(1),$2)
endef


# Generates the dir prerequisite for an implicit rule
define implicit_dir_prereq
$(if $(filter $(SCAFFOLD_SOURCE_DIR),$(SCAFFOLD_BUILD_DIR)),,$$(@D)/.scaffold-dir)
endef

# Generates teh dire prerequisite for a target
define target_dir_prereq
$(if $(filter $(SCAFFOLD_SOURCE_DIR),$(SCAFFOLD_BUILD_DIR)),,$(dollar)$(dollar)(@D)/.scaffold-dir)
endef
