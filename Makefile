# global cxx flags used by all g++ invocations
CXXFLAGS += -g -Wall -pedantic

# global linker options
linker_opts := -rpath,$(CURDIR)/lib

# the directories to copy all binaries to
bin_dir += bin

# the include directories
include_dirs += .

# the directories to copy all shared libraries to
lib_dir += lib

# directory to append to the directory of the object files
obj_dir := .obj

include build.mk


.PHONY: all line-count docs plugin-make plugin module.mk plugins etags sources

all: programs libraries
