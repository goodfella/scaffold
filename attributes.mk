# defines for attributes, unless otherwise noted, the first argument
# to the function is the name of the object


# this enables us to put commas in variables
, := ,

# 1 = name of object
# 2 = name of attribute
define attribute
$($(1)_$(2))
endef

# global attributes

# places to copy the object to
define cp_dest
$(call attribute,$1,$0)
endef

# places to create symlinks to the object to
define ln_dest
$(call attribute,$1,$0)
endef


# compiled object attributes

# flags for C compiler
define ccflags
$(call attribute,$1,$0)
endef

# flags for C++ compiler
define cxxflags
$(call attribute,$1,$0)
endef

# C preprocessor flags
define cppflags
$(call attribute,$1,$0)
endef

# include directories
define incdirs
$(call attribute,$1,$0)
endef


# target attributes

# libraries that need to be built before the target that the target
# links against
define prelibs
$(call attribute,$1,$0)
endef

# linker options for gcc -rdynamic, -shared etc.
define ldflags
$(call attribute,$1,$0)
endef

# comma deliminated list of options to pass to linker
define linkopts
$(if $(call attribute,$1,$0),-Wl$(,)$(call attribute,$1,$0))
endef

# directories to find libraries in -L
define libdirs
$(call attribute,$1,$0)
endef

# system libraries to link against -l
define libs
$(call attribute,$1,$0)
endef

# source files for the target
define srcs
$(call attribute,$1,$0)
endef

# source cxxflags to apply to all source specified in the srcs
# attribute
define src_cxxflags
$(call attribute,$1,$0)
endef
