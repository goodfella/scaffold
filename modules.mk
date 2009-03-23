# generates the rules to build the targets in the module.mk files


# directory the module is in
module_dir = $(dir $(lastword $(MAKEFILE_LIST)))


# path relative to the top level Makefile
# usage
# 1 = filenames
define relpath
$(addprefix $(module_dir),$1)
endef


# converts the extension of a file

# 1 = file
# 2 = new extension
define change_ext
$(foreach src,$1,$(patsubst %$(suffix $(src)),%.$2,$(src)))
endef


# converts the source suffix to the object file suffix

# 1 = file
# 2 = object extension
define src_obj
$(call change_ext,$1,$2)
endef


# creates the src_cxxflags for the sources of the target

# 1 = target
define create_src_cxxflags
$(foreach src,$(call srcs,$1),
              $(eval $(call relpath,$(src))_cxxflags+=$(call src_cxxflags,$1)))
endef


# generates the prelib depends string

# 1 = target
define create_prelib_depends
$(foreach prelib,$(call prelibs,$1),$(value prelib_$(prelib)))
endef


# generates the object depends string

# 1 = target
# 2 = object file suffix
define create_obj_depends
$(call relpath,$(call src_obj,$(call srcs,$1),$2))
endef


# processes a module.mk file
define process_module

# create the rules for the programs defined in the module
$(foreach prog,$(local_cxxprogs),$(eval $(call cxxprog_rule,$(prog))))

sources += $(call relpath,$(local_src))
cxxprograms += $(call relpath,$(local_cxxprogs))
shared_libraries += $(call relpath,$(local_shared_lib))
plugins += $(call relpath,$(local_plug))

# reset module variables
local_cxxprogs :=
local_shared_lib :=
local_src :=
local_plug :=

endef


# creates the rule for a C++ program

# 1 = program name
define cxxprog_rule

# checks to make sure a srcs variable is declared
$(if $(call srcs,$1),,$(error program $(1) is missing a $(1)_srcs variable))

# sets the src files cxxflags
$(call create_src_cxxflags,$1)

# rule to create the program.  The dependencies are the object files
# obtained from the source files as well as the prelibs specified in
# the module.mk
$(call relpath,$1): $(call create_obj_depends,$1,$(cxx_prog_obj)) \
                    $(call create_prelib_depends,$1)

	$(call gxx,$(CXXFLAGS) \
                   $(CPPFLAGS) \
                   $(LDFLAGS) \
                   $(call inc_dirs,$(include_dirs)) \
                   $(call lib_dirs,$(library_dirs)) \
                   $(call cxxflags,$1) \
                   $(call cppflags,$1) \
                   $(call inc_dirs,$(call incdirs,$1)) \
                   $(call lib_dirs,$(call libdirs,$1)) \
                   $(call linkopts,$1) \
                   $(call ldflags,$1) \
                   $(call link_libs,$(call libs,$1)) \
                   $(call link_libs,$(call prelibs,$1)), \
                   $$@,$$(filter %.$(cxx_prog_obj),$$^))
endef
