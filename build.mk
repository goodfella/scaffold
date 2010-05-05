# Copyright (C) 2009 Nicholas Guiffrida

# this file should be included by the projects top level Makefile.  It
# defines the default build and clean targets

include $(dir $(lastword $(MAKEFILE_LIST)))variables.mk
include $(dir $(lastword $(MAKEFILE_LIST)))attributes.mk
include $(dir $(lastword $(MAKEFILE_LIST)))commands.mk
include $(dir $(lastword $(MAKEFILE_LIST)))functions.mk
include $(dir $(lastword $(MAKEFILE_LIST)))module-helper.mk
include $(dir $(lastword $(MAKEFILE_LIST)))modules.mk


# these are variables filled in by the module.mk files

# all the sources
sources :=

# all the object files
object_files :=

# all the C++ programs
cxx_progs :=

# all the C++ shared libraries
cxx_shlibs :=

# all the dependency files generated from the object files
dependencies := $(shell find -name '*.d')

# module.mk files
modules := $(shell find -name 'module.mk')


# clean_files: files to delete with the clean-files target

# obj_dir: directory to place the object files in.  The path specified
# here is relative to the object file's source file

# list of directories with headers
include_dirs +=

.PHONY: clean-build clean-targets clean-files clean-dirs clean-all \
        programs libraries make_obj_dirs pre_build

ifneq ($(MAKECMDGOALS),clean)
include $(dependencies)
endif

include $(modules)

libraries: $(cxx_shlibs)
programs: $(cxx_progs)


# cleans out all the files generated by the build including the object
# file directories
clean-build:
	rm -f $(object_files) $(dependencies)

	$(if $(obj_dir),-rmdir $(sort $(dir $(object_files))))


# removes the targets
clean-targets:
	rm -f $(cxx_progs) $(cxx_shlibs)


# removes all the files specified in the clean_files variable
clean-files:
	rm -f $(clean_files)


clean-all: clean-build clean-targets clean-files
