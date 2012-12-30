# Copyright (C) 2009 Nicholas Guiffrida

# this file should be included by the projects top level Makefile.  It
# defines the default build and clean targets

# check for required make features
ifeq ($(.FEATURES),)
$(error Scaffold requires the .FEATURES variable)
endif

ifeq ($(filter target-specific,$(.FEATURES)),)
$(error Scaffold requires target specific variables)
endif

ifeq ($(filter second-expansion,$(.FEATURES)),)
$(error Scaffold requires secondary expansion)
endif

ifeq ($(filter order-only,$(.FEATURES)),)
$(error Scaffold requires order only prerequisites)
endif


# Defined here so immediate expansion occurs
SCAFFOLD_DEPENDENCIES :=

# Directory where make was invoked
export SCAFFOLD_BUILD_DIR ?= $(CURDIR)/

# Directory where the source code lives
export SCAFFOLD_SOURCE_DIR ?= $(dir $(realpath $(filter %Makefile,$(MAKEFILE_LIST))))

ifeq ($(strip $(realpath $(SCAFFOLD_BUILD_DIR)Makefile)),)

# The out of source Makefile does not exist, so make it

# Target to build the out of source Makefile.  This is the default
# goal, which will generate the Makefile
$(SCAFFOLD_BUILD_DIR)Makefile:
	@echo "export SCAFFOLD_BUILD_DIR := $(SCAFFOLD_BUILD_DIR)" >> $@
	@echo "export SCAFFOLD_SOURCE_DIR := $(SCAFFOLD_SOURCE_DIR)" >> $@
	@echo "all:" >> $@
	@printf "\t@echo SCAFFOLD_BUILD_DIR = $(SCAFFOLD_BUILD_DIR)\n" >> $@
	@printf "\t@echo SCAFFOLD_SOURCE_DIR = $(SCAFFOLD_SOURCE_DIR)\n" >> $@
	@printf "\t\$$(MAKE) -C $(SCAFFOLD_SOURCE_DIR) all\n" >> $@
	@echo ".DEFAULT:" >> $@
	@printf "\t\$$(MAKE) --print-directory -C $(SCAFFOLD_SOURCE_DIR) \$$(MAKECMDGOALS)\n" >> $@

else

ifneq ($(strip $(filter help,$(MAKECMDGOALS))),)

# Help target is requsted, so print it

.PHONY: help
help:
	@printf 'Generic targets:\n'
	@printf '  all\t\t\t\t- Builds all targets\n'
	@printf '  scaffold-programs\t\t- Builds all the programs\n'
	@printf '  scaffold-libraries\t\t- Builds all the libraries\n'
	@printf '\nCleaning targets:\n'
	@printf '  clean\t\t\t\t- Cleans programs, libraries, and build artifacts\n'
	@printf '  clean-pmk\t\t\t- Cleans the precompiled module files\n'
	@printf '  clean-all\t\t\t- Runs clean and clean-pmk\n'
	@printf '\nDebugging targets:\n'
	@printf '  <module-dir>/module.mk.out\t- Outputs the processing of a module.mk file\n'
	@printf '\t\t\t\t  <module-dir> is the path relative to\n'
	@printf '\t\t\t\t  the source directory of the module file\n'
else

# normal target
.DEFAULT_GOAL: all

SCAFFOLD_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Either the out of source Makefile exists, or this isn't an out of
# source build

include $(SCAFFOLD_DIR)variables.mk
include $(SCAFFOLD_DIR)attributes.mk
include $(SCAFFOLD_DIR)commands.mk
include $(SCAFFOLD_DIR)module-helper.mk
include $(SCAFFOLD_DIR)modules.mk


# Normalize the scaffold module paths
SCAFFOLD_MODULES := $(abspath $(SCAFFOLD_MODULES))

# Derive the .pmk paths from the module.mk paths
SCAFFOLD_MODULES_PMK := $(call precompiled_modules,$(SCAFFOLD_MODULES))

# Secondary expansion is used to expand variables that contain the
# full paths to libraries built in this build.  Each library's path
# variable is set when processing a .pmk file, so after all the pmk
# files have been included, make will expand the library directory
# variables referenced in library and program rules
.SECONDEXPANSION:

# Pattern rule to build a .pmk file from a .mk file
$(SCAFFOLD_BUILD_DIR)%.pmk : $(SCAFFOLD_SOURCE_DIR)%.mk $(call implicit_dir_prereq)
	$(MAKE) -s -f $(SCAFFOLD_DIR)print-module.mk $< > $@


ifeq ($(filter %.mk.out,$(MAKECMDGOALS)),)

# Only include the .pmk files if a .mk.out print out is not requested

# force creation of a .pmk file for each .mk file
include $(SCAFFOLD_MODULES_PMK)

endif

.PHONY: clean clean-all clean-pmk scaffold_programs scaffold_libraries all scaffold-process-modules
clean-all: clean-pmk clean


ifeq ($(filter clean%,$(MAKECMDGOALS)),)
-include $(SCAFFOLD_DEPENDENCIES)
endif

scaffold_libraries: $(SCAFFOLD_LIBRARIES)
scaffold_programs: scaffold_libraries $(SCAFFOLD_PROGRAMS)
all: scaffold_programs

# Special target for testing
scaffold-process-modules: ;

# Outputs a processed module.mk to standard out
%.mk.out: %.mk
	cat $^
	@$(MAKE) -s -f $(SCAFFOLD_DIR)print-module.mk $^

# Creates a directory.  The file is marked as precious to prevent its
# deletion
.PRECIOUS: %.scaffold-dir
%.scaffold-dir:
	@-mkdir -p $(@D)
	@touch $@

endif # help target condition
endif # out of source build condition
