# generates the rules to build the targets in a module.mk file

# 1 = library name
define linker_name
lib$(1).so
endef


# 1 = library name
define soname
$(call linker_name,$(1)).$(call version,$(1))
endef

# 1 = library name
define real_name
$(call soname,$(1)).$(call minor,$1).$(call release,$1)
endef


# 1 = library name
define shlib_linker_name_target
$(call relpath,$(call linker_name,$(1)))
endef


# 1 = library name
define shlib_real_name_target
$(call relpath,$(call real_name,$1))
endef


# called from a module.mk file, this sets up the neccessary targets
# for the objects defined in a module.mk
define process_module

# creates variables for source attributes
$(foreach src,$(local_srcs),$(eval $(call src_vars,$(src))))


# create the rules for the C++ programs defined in the module
$(foreach prog,$(local_cxx_progs),$(eval $(call cxx_prog_rule,$(prog))))


# create the rules for the C++ shared libraries
$(foreach shlib,$(local_cxx_shlibs),$(eval $(call cxx_shlib_rule,$(shlib))))


sources += $(call relpath,$(local_srcs))
cxxprograms += $(call relpath,$(local_cxx_progs))
shared_libraries += $(call relpath,$(local_cxx_shlibs))
plugins += $(call relpath,$(local_plugs))

# reset module variables
local_cxx_progs :=
local_cxx_shlibs :=
local_srcs :=
local_plugs :=

endef


# creates the rule for a C++ program

# 1 = program name
define cxx_prog_rule

# checks to make sure a srcs variable is declared
$(if $(call srcs,$1),,$(error program $(1) is missing a $(1)_srcs variable))

# sets the src files cxxflags
$(call create_src_var,$(call srcs,$1),cxxflags,$(call src_cxxflags,$1))

# sets the src files cppflags
$(call create_src_var,$(call srcs,$1),cppflags,$(call src_cppflags,$1))

object_files += $(call obj_depends,$1,$(cxx_prog_obj))


# rule to create the program.  The dependencies are the object files
# obtained from the source files, and the prelibs, and the pre_rules
# specified in the module.mk
$(call relpath,$1): $(call obj_depends,$1,$(cxx_prog_obj)) $(call prelib_depends,$1) | $(call pre_rules,$1)

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
                   $$@,$$(filter %.$(cxx_prog_obj),$$^))

	$(if $(bin_dir),$(call cp,$(call relpath,$1),$(bin_dir)))

$(call reset_attributes,$1)
endef


# rule to create C++ shared libraries.
# 1 = shared library name
define cxx_shlib_rule

# check if srcs variable is set
$(if $(call srcs,$1),,$(error shared library $(1) is missing a $(1)_srcs variable))

# check if version variable is set
$(if $(call version,$1),,$(error shared library $(1) is missing a $(1)_version variable))

# check if minor variable is set
$(if $(call minor,$1),,$(error shared library $(1) is missing a $(1)_minor variable))

# check if release variable is set
$(if $(call release,$1),,$(error shared library $(1) is missing a $(1)_release variable))

object_files += $(call obj_depends,$1,$(cxx_shlib_obj))


# sets the src files cxxflags
$(call create_src_var,$(call srcs,$1),cxxflags,$(call src_cxxflags,$1))

# sets the src files cppflags
$(call create_src_var,$(call srcs,$1),cppflags,$(call src_cppflags,$1))


# library rules

# prelib target for programs

# prelib_<library-name>: /path/to/lib/lib<library-name>.so.<version>.<minor>.<release>
$(call prelib_target,$1): $(call shlib_real_name_target,$1)

# /path/to/lib/lib<library-name>.so: /path/to/lib/lib<library-name>.so.<version>.<minor>.<release>
$(call shlib_linker_name_target,$1): $(call shlib_real_name_target,$1)

# /path/to/lib/lib<lib-name>.so.<version>.<minor>.<release>: <object files> <prelibs> | <pre_rule>
$(call shlib_real_name_target,$1): $(call obj_depends,$1,$(cxx_shlib_obj)) $(call prelib_depends,$1) | $(call pre_rule,$1)

	$(call gxx,-shared -Wl$(,)-soname$(,)$(call soname,$1) \
                   $(CXXFLAGS) \
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
                   $$@,$$(filter %.$(cxx_shlib_obj),$$^))

	ln -snf $$(notdir $$@) $$(dir $$@)$(call soname,$1)
	ln -snf $$(notdir $$@) $$(dir $$@)$(call linker_name,$1)

$(call reset_attributes,$1)
endef


# handles local_srcs in a module.mk

# 1 = source file name
define src_vars

# create a variable for each source attribute
$(call create_src_var,$1,cxxflags,$(call cxxflags,$1))
$(call create_src_var,$1,cppflags,$(call cppflags,$1))
$(call create_src_var,$1,incdirs,$(call incdirs,$1))
$(call reset_attributes,$1)
endef
