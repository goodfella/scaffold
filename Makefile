# global cxx flags used by all g++ invocations
CXXFLAGS += -g -Wall -pedantic

# the include directories
INCDIRS += include .

include build.mk


.PHONY: all line-count docs plugin-make plugin module.mk plugins etags sources

all: programs libraries
