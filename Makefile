# include the project specific settings
include project.mk

# Makefile command line args go here


CXXFLAGS += -g -Wall -pedantic

# the directories to copy all binaries to
bin_dir += bin

# the include directories
include_dirs +=

# the directories to copy all shared libraries to
library_dir += lib

# set the path to the build directory to include the build system
build_dir := .
include $(build_dir)/build.mk


.PHONY: all clean clean-build clean-targets line-count docs plugin-make plugin module.mk plugins etags sources

all: libraries programs sources

clean: clean-build
clean-all: clean-build clean-targets
