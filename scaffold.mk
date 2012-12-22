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
	@printf "\t\$$(MAKE) -C $(SCAFFOLD_SOURCE_DIR) all\n" >> $@
	@echo ".DEFAULT:" >> $@
	@printf "\t\$$(MAKE) --print-directory -C $(SCAFFOLD_SOURCE_DIR) \$$(MAKECMDGOALS)\n" >> $@

else

.DEFAULT_GOAL: all

SCAFFOLD_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Either the out of source Makefile exists, or this isn't an out of
# source build

include $(SCAFFOLD_DIR)variables.mk
include $(SCAFFOLD_DIR)attributes.mk
include $(SCAFFOLD_DIR)commands.mk
include $(SCAFFOLD_DIR)module-helper.mk
include $(SCAFFOLD_DIR)modules.mk

# Generates the rule to build a precompiled module

# 1 = The path to the precomiled module's source
define build_precompiled_module
$(call precompiled_modules,$1): $1
	@mkdir -p $$(@D)
	$$(MAKE) -s -f $(SCAFFOLD_DIR)print-module.mk $$^ > $$@

endef

# Generate the precompile module targets
$(foreach mk,$(SCAFFOLD_MODULES),$(eval $(call build_precompiled_module,$(mk))))


.SECONDEXPANSION:

# Derive the .pmk paths from the module.mk paths
SCAFFOLD_MODULES_PMK := $(call precompiled_modules,$(SCAFFOLD_MODULES))

# force creation of a .pmk file for each .mk file
include $(SCAFFOLD_MODULES_PMK)

.PHONY: clean clean-all clean-pmk scaffold_programs scaffold_libraries all
clean-all: clean-pmk clean


ifeq ($(filter clean%,$(MAKECMDGOALS)),)
-include $(SCAFFOLD_DEPENDENCIES)
endif

scaffold_libraries: $(SCAFFOLD_LIBRARIES)
scaffold_programs: scaffold_libraries $(SCAFFOLD_PROGRAMS)
all: scaffold_programs

# Special target for testing
scaffold-process-modules: ;

endif
