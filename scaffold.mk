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

SCAFFOLD_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(SCAFFOLD_DIR)variables.mk
include $(SCAFFOLD_DIR)attributes.mk
include $(SCAFFOLD_DIR)commands.mk
include $(SCAFFOLD_DIR)module-helper.mk
include $(SCAFFOLD_DIR)modules.mk


# 1 = module path
define create_module_targets
$(eval include $(1))
$(call process_module_targets)
endef


.SECONDEXPANSION:
# create the targets
$(foreach module,$(SCAFFOLD_MODULES),$(eval $(call create_module_targets,$(module))))

# clean_files: files to delete with the clean-files target

.PHONY: scaffold-clean-build scaffold-clean-targets scaffold-clean-files clean-all scaffold_programs scaffold_libraries


ifneq ($(MAKECMDGOALS),clean)
-include $(SCAFFOLD_DEPENDENCIES)
endif

scaffold_libraries: $(SCAFFOLD_LIBRARIES)
scaffold_programs: $(SCAFFOLD_PROGRAMS)


# cleans out all intermediate files generated by the build
scaffold-clean-build:
	rm -f $(SCAFFOLD_OBJ_FILES) $(SCAFFOLD_DEPENDENCIES)

# removes the targets
scaffold-clean-targets:
	rm -f $(SCAFFOLD_PROGRAMS) $(SCAFFOLD_LIBRARIES) $(SCAFFOLD_TARGET_CLEAN)


# removes all the files specified in the SCAFFOLD_CLEAN_FILES variable
scaffold-clean-files:
	$(if $(SCAFFOLD_CLEAN_FILES),rm -f $(SCAFFOLD_CLEAN_FILES),)

clean-all: scaffold-clean-build scaffold-clean-targets scaffold-clean-files

%.mk.out: %.mk
	cat $^
	@$(MAKE) -s -f $(SCAFFOLD_DIR)print-module.mk $^
