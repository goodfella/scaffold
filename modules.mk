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

# 1 = files
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


# creates the variable that stores the value of a attribute for a list
# of sources

# 1 = list of sources
# 2 = attribute
# 3 = attribute values
define create_src_var
$(foreach src,$1,$(eval $(call relpath,$(src))_$(2)+=$3))
endef


# generates the prelib depends string

# 1 = target
define create_prelib_depends
$(foreach prelib,$(call prelibs,$1),$(value prelib_$(prelib)))
endef


# generates the object depends string

# 1 = target
define create_obj_depends
$(call relpath,$(call src_obj,$(call srcs,$1),o))
endef


# processes a module.mk file
define process_module

# create the rules for the programs defined in the module
$(foreach prog,$(local_cxxprogs),$(eval $(call cxxprog_rule,$(prog))))


# creates variables for source attributes
$(foreach src,$(local_srcs),$(eval $(call src_attrs,$(src))))


sources += $(call relpath,$(local_srcs))
cxxprograms += $(call relpath,$(local_cxxprogs))
shared_libraries += $(call relpath,$(local_shared_libs))
plugins += $(call relpath,$(local_plugs))

# reset module variables
local_cxxprogs :=
local_shared_libs :=
local_srcs :=
local_plugs :=

endef


# creates the rule for a C++ program

# 1 = program name
define cxxprog_rule

# checks to make sure a srcs variable is declared
$(if $(call srcs,$1),,$(error program $(1) is missing a $(1)_srcs variable))

# sets the src files cxxflags
$(call create_src_var,$(call srcs,$1),cxxflags,$(call src_cxxflags,$1))

# rule to create the program.  The dependencies are the object files
# obtained from the source files as well as the prelibs specified in
# the module.mk
$(call relpath,$1): $(call create_obj_depends,$1) \
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
                   $$@,$$(filter %.o,$$^))
endef


# creates the variables for each source attribute

# 1 = source file name
define src_attrs
$(call create_src_var,$1,cxxflags,$(call cxxflags,$1))
$(call create_src_var,$1,cppflags,$(call cppflags,$1))
endef