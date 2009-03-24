# include the project specific settings
include project.mk

# set the path to the build directory to include the build system
build_dir := .
include $(build_dir)/build.mk

# Makefile command line args go here


CXXFLAGS += -g -Wall -pedantic

# the directories to copy all binaries to
bin_dir := bin

# the include directories
include_dirs :=

# the directories to copy all shared libraries to
library_dirs := lib


# these are variables filled in by the module.mk files
sources :=
cxxprograms :=
shared_libraries :=
plugins :=

# all the dependency files in the project
dependencies := $(shell find -name '*.d')

modules := $(shell find -name 'module.mk')

.PHONY: all clean line-count docs plugin-make plugin module.mk plugins etags

all: libraries programs

include $(modules)

libraries: $(shared_libraries)
programs: $(cxxprograms)
plugins: $(plugins)

clean:
	rm -f $(shell find -name *.o -o \
                           -name *.$(shared_lib_obj) -o \
                           -name '*.d' -o \
                           -name '*~' -o \
                           -name 'semantic.cache' -o \
                           -name '*.so.*') \
             $(cxxprograms) \
              bin/* \
              lib/*

ifneq ($(MAKECMDGOALS),clean)
include $(dependencies)
endif