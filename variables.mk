# Copyright (C) 2009 Nicholas Guiffrida

# global variables used by the build system

# simply expanded so it can be appended to with attributes
SCAFFOLD_INCDIRS :=
SCAFFOLD_OBJ_SUFFIX := o
SCAFFOLD_CXX_OBJ_SUFFIX := cxx.o
SCAFFOLD_FPIC ?= -fPIC
SCAFFOLD_DEPENDS_SUFFIX := .d
SCAFFOLD_PMK_SUFFIX := .pmk
SCAFFOLD_CXX_SUFFIXES := cpp cc

semi_colon := ;
comma := ,
dollar = $$
