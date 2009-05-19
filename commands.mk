# Copyright (C) 2009 Nicholas Guiffrida

# contains defines for commands used in the build process and sets up
# abbreviated outputs

# this arg determines how verbose the output is
ifdef V
  ifeq ("$(origin V)", "command line")
    BUILD_VERBOSE = $(V)
  endif
endif

ifndef BUILD_VERBOSE
  BUILD_VERBOSE := 0
endif

# if BUILD_VERBOSE equals 0 then we output the abbreviated commands

# if BUILD_VERBOSE equals 1 then we output the whole command

# if BUILD_VERBOSE equals 2 then both the whole and abbreviated
# command is outputed this should only be used for debugging the build
# system

# this is a trick adopted from the linux kernel KBuild
ifeq ($(BUILD_VERBOSE),1)
abbrv :=
Q :=
else
abbrv := a
Q := @
endif

ifeq ($(BUILD_VERBOSE),2)
abbrv := a
Q :=
endif


# abbreviated command names
a_gxx := CXX
a_echo := @echo -e
a_cp := CP
a_ln := LN


# echos the abbrieviated name of the command

# usage
# 1 = command
# 2 = target string
define abbrv_cmd
$(if $($(abbrv)_echo),$($(abbrv)_echo) $(a_$1) \\t $2)
endef


# gcc to compile programs
# usage
# 1 = list of arguments
# 2 = target name
# 3 = infiles
define gxx
$(call abbrv_cmd,$0,$(2))
	$(Q)$(CXX) $(1) -o $2 $3


endef


# copies a list of files to a directory, if the directory does not
# exist, it will be created

# 1 = list of files to copy
# 2 = destination
define cp
	$(call abbrv_cmd,$0,$1 "->" $2)
	@mkdir -p $2
	$(Q)cp -t $2 $1
endef


# creates a symlink

# 1 = source file path
# 2 = symlink path
define ln
$(call abbrv_cmd,$0,$1 "->" $2)
	$(Q)ln -snf $1 $2
endef
