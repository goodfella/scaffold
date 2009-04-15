# generates the rules to build the targets in a module.mk file

# called from a module.mk file, this sets up the neccessary targets
# for the objects defined in a module.mk
define process_module

# create the rules for the programs defined in the module
$(foreach prog,$(local_cxxprogs),$(eval $(call cxxprog_rule,$(prog))))


# creates variables for source attributes
$(foreach src,$(local_srcs),$(eval $(call src_vars,$(src))))


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

# sets the src files cppflags
$(call create_src_var,$(call srcs,$1),cppflags,$(call src_cppflags,$1))

object_files += $(call create_obj_depends,$1)

# rule to create the program.  The dependencies are the object files
# obtained from the source files as well as the prelibs specified in
# the module.mk
$(call relpath,$1): $(call create_obj_depends,$1) \
                    $(call create_prelib_depends,$1)

	$(call gxx,$(CXXFLAGS) \
                   $(call cxxflags,$1) \
                   $(CPPFLAGS) \
                   $(call cppflags,$1) \
                   $(LDFLAGS) \
                   $(call ldflags,$1) \
                   $(call inc_dirs,$(include_dirs)) \
                   $(call inc_dirs,$(call incdirs,$1)) \
                   $(call lib_dirs,$(library_dirs)) \
                   $(call lib_dirs,$(call libdirs,$1)) \
                   $(call linkopts,$1) \
                   $(call link_libs,$(call libs,$1)) \
                   $(call link_libs,$(call prelibs,$1)), \
                   $$@,$$(call obj_path,$$(filter %.o,$$^)))

	$(if $(bin_dir),$(call cp,$(call relpath,$1),$(bin_dir)))
endef


# handles local_srcs in a module.mk

# 1 = source file name
define src_vars

# create a variable for each source attribute
$(call create_src_var,$1,cxxflags,$(call cxxflags,$1))
$(call create_src_var,$1,cppflags,$(call cppflags,$1))
endef
