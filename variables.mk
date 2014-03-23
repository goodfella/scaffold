# Copyright (C) 2009 Nicholas Guiffrida

# global variables used by the build system

# SCAFFOLD_INCDIRS is simply expanded so it can be appended to with
# attributes that also need to be simply expanded
SCAFFOLD_INCDIRS :=

SCAFFOLD_OBJ_SUFFIX := o
SCAFFOLD_FPIC ?= -fPIC
SCAFFOLD_DEPENDS_SUFFIX := .d
SCAFFOLD_PMK_SUFFIX := .pmk
SCAFFOLD_CXX_SUFFIXES += cpp cc

semi_colon := ;
comma := ,
dollar = $$
