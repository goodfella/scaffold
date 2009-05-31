# Copyright (C) 2009 Nicholas Guiffrida

# this file should be included by the projects top level Makefile.  It
# defines the default build and clean targets

include $(build_dir)/variables.mk
include $(build_dir)/attributes.mk
include $(build_dir)/commands.mk
include $(build_dir)/functions.mk
include $(build_dir)/module-helper.mk
include $(build_dir)/modules.mk


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

# bin_dir: directory to copy binaries to

# bin_dir_files: files that are copied into bin_dir.  This variable is
# used to delete all the files from bin_dir

# lib_dir: directory to copy libraries to

# lib_dir_files: files that are copied into lib_dir.  This variable is
# used to delete all the files from lib_dir.  Only file names should
# be added to this variable

# obj_dir: directory to place the object files in.  The path specified
# here is relative to the object file's source file

# library_dirs: list of directories where the shared libraries for
# this project are built from

# list of directories with headers
include_dirs +=

.PHONY: clean-build clean-targets clean-files clean-dirs clean-all \
        programs libraries make_obj_dirs make_bin_dir make_lib_dir pre_build

ifneq ($(MAKECMDGOALS),clean)
include $(dependencies)
endif

include $(modules)


# things that need to be done before building the targets
pre_build: make_lib_dir make_bin_dir make_obj_dirs

# generates the object directories
make_obj_dirs:
	@mkdir -p $(sort $(dir $(object_files)))

make_bin_dir:
	$(if $(bin_dir),@-mkdir -p $(bin_dir))

make_lib_dir:
	$(if $(lib_dir),@-mkdir -p $(lib_dir))


libraries: pre_build $(cxx_shlibs)
programs: pre_build $(cxx_progs)


# cleans out all the files generated by the build including the object
# file directories
clean-build:
	rm -f $(object_files) $(dependencies)

	$(if $(obj_dir),-rmdir $(sort $(dir $(object_files))))


# removes the targets
clean-targets:
	rm -f $(cxx_progs) $(cxx_shlibs)


# removes the binary directory and the library directory
clean-dirs:
	$(if $(bin_dir),rm -f $(addprefix $(bin_dir)/,$(bin_dir_files)))
	$(if $(lib_dir),rm -f $(addprefix $(lib_dir)/,$(lib_dir_files)))
	$(if $(bin_dir),-rmdir $(bin_dir))
	$(if $(lib_dir),-rmdir $(lib_dir))


# removes all the files specified in the clean_files variable
clean-files:
	rm -f $(clean_files)


clean-all: clean-build clean-targets clean-dirs clean-files
