
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

SCAFFOLD_DEPENDENCIES :=

SCAFFOLD_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(SCAFFOLD_DIR)variables.mk
include $(SCAFFOLD_DIR)attributes.mk
include $(SCAFFOLD_DIR)commands.mk
include $(SCAFFOLD_DIR)module-helper.mk
include $(SCAFFOLD_DIR)modules.mk


.SECONDEXPANSION:

# Derive the .pmk paths from the module.mk paths
SCAFFOLD_MODULES_PMK := $(call precompiled_modules,$(SCAFFOLD_MODULES))

# force creation of a .pmk file for each .mk file
include $(SCAFFOLD_MODULES_PMK)

clean-all: clean-pmk clean
.PHONY: clean scaffold_programs scaffold_libraries all


ifeq ($(filter clean%,$(MAKECMDGOALS)),)
-include $(SCAFFOLD_DEPENDENCIES)
endif

scaffold_libraries: $(SCAFFOLD_LIBRARIES)
scaffold_programs: scaffold_libraries $(SCAFFOLD_PROGRAMS)

all: scaffold_programs

# Generates a precompiled module.mk file to be included by scaffold
%.pmk : %.mk
	$(MAKE) -s -f $(SCAFFOLD_DIR)print-module.mk $^ > $@


# Outputs a processed module.mk to standard out
%.mk.out: %.mk
	cat $^
	@$(MAKE) -s -f $(SCAFFOLD_DIR)print-module.mk $^
