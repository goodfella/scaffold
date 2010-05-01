# global cxx flags used by all g++ invocations
CXXFLAGS += -g -Wall -pedantic

# the include directories
include_dirs += include .

# directory to append to the directory of the object files
obj_dir := .obj

include build.mk


.PHONY: all line-count docs plugin-make plugin module.mk plugins etags sources

all: programs libraries
