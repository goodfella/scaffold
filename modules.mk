# Copyright (C) 2009 Nicholas Guiffrida

# generates the rules to build the targets in a module.mk file

# 1 = library name or path
define linker_name
$(dir $1)lib$(notdir $1).so
endef


# 1 = library name
define soname
$(call linker_name,$(1)).$(call version,$(notdir $1))
endef


# 1 = library name
define real_name
$(call soname,$(1)).$(call minor,$(notdir $1)).$(call release,$(notdir $1))
endef


# 1 = object name
define prelib_depends
$(foreach prelib,$(call prelibs,$1),$(call linker_name,$(prelib)))
endef


# compiles a single source file into an object file

# 1 = path of object file
# 2 = path of source file
# 3 = extra flags
define compile_source
$(call gxx,$(CXXFLAGS) \
           $$(call cxxflags,$2) \
           $(CPPFLAGS) \
           $$(call cppflags,$2) \
           $(call inc_dirs,$(include_dirs)) \
           $$(call inc_dirs,$$(call incdirs,$2)) $3 -c,$(1),$(2))
endef


# creates the depends file for an object file

# 1 = target path
# 2 = infile path
define make_depends
$(call gxx_noabbrv,-M -MM -MD -MT $(1) $(include_dirs:%=-I%) \
           $(call cppflags,$2) $(call inc_dirs,$(call incdirs,$2)),\
           $(addsuffix .d,$1),$2)

endef


# returns an object file given a source file

# 1 = source file
# 2 = object file suffix
define obj_file
$(if $(obj_dir),$(addsuffix .$(2),$(basename $(dir $(1))$(subst //,/,$(obj_dir)/)$(notdir $(1)))),
                $(addsuffix .$(2),$(basename $(1))))
endef

# returns a list of object files given a list of full pathed source
# files

# 1 = list of source files
# 2 = object file suffix
define obj_files
$(foreach src,$(1),$(call obj_file,$(src),$(2)))
endef


define process_module_vars

# create the rules for the C++ shared libraries
$(foreach shlib,$(local_cxx_shlibs),$(call cxx_shlib_vars,$(shlib),\
                                                          $(call relpath,$(shlib))))

$(call reset_module_vars)
endef

# called from a module.mk file, this sets up the neccessary targets
# for the objects defined in a module.mk
define process_module_targets

# creates variables for source attributes
$(foreach src,$(local_srcs),$(call src_vars,$(src)))


# create the rules for the C++ shared libraries
$(foreach shlib,$(local_cxx_shlibs),$(call cxx_shlib_rule,$(shlib),\
                                                          $(call relpath,$(shlib)),\
                                                          $(call relpath,$(call srcs,$(shlib))),\
                                                          $(call obj_files,$(call relpath,$(call srcs,$(shlib))),$(cxx_shlib_obj))))

# # create the rules for the C++ programs defined in the module
$(foreach prog,$(local_cxx_progs),$(call cxx_prog_rule,$(prog),\
                                                       $(call relpath,$(prog)),\
                                                       $(call relpath,$(call srcs,$(prog))),\
                                                       $(call obj_files,$(call relpath,$(call srcs,$(prog))),$(cxx_prog_obj))))

sources += $(call relpath,$(local_srcs))
cxx_progs += $(call relpath,$(local_cxx_progs))
plugins += $(call relpath,$(local_plugs))

$(call reset_module_vars)

endef


# creates the rule for an object file

# 1 = source file path
# 2 = object file suffix
# 3 = extra gcc args
define obj_rule
$(call obj_file,$(1),$(2)) : $1
	@mkdir -p $$(dir $$@)
	$(call make_depends,$$@,$$<)
	$(call compile_source,$$@,$$<,$3)
endef


# creates the rule for a C++ program

# 1 = program name
# 2 = program full path
# 3 = full pathed program sources
# 4 = full pathed program object files
define cxx_prog_rule

# checks to make sure a srcs variable is declared
$(if $(3),,$(error program $(1) is missing a $(1)_srcs variable))

# sets the src files cxxflags
$(call create_src_var,$(3),cxxflags,$(call src_cxxflags,$1))

# sets the src files cppflags
$(call create_src_var,$(3),cppflags,$(call src_cppflags,$1))

sources += $(3)
object_files += $(4)


# rule to create the program.  The dependencies are the object files
# obtained from the source files, and the prelibs, and pre_rules
# specified in the module.mk

# /path/to/program : <prelibs> <object files> | <pre-rules>
$(2): $(call prelib_depends,$1) $(4) | $(call pre_rules,$1)

	$(call gxx,$(CXXFLAGS) \
                   $(call cxxflags,$1) \
                   $(CPPFLAGS) \
                   $(call cppflags,$1) \
                   $(LDFLAGS) \
                   $(call ldflags,$1) \
                   $(call inc_dirs,$(include_dirs)) \
                   $(call inc_dirs,$(call incdirs,$1)) \
                   $(call lib_dirs,$(dir $(call prelibs,$1))) \
                   $(call lib_dirs,$(call libdirs,$1)) \
                   $(call linkopts,$1) \
                   $(call link_opts_string,$(linker_opts)) \
                   $(call link_libs,$(call libs,$1)) \
                   $(call link_libs,$(notdir $(call prelibs,$1))), \
                   $$@,$$(filter %.$(cxx_prog_obj),$$^))

# generate the rules for each object file
$(foreach src,$(3),$(call obj_rule,$(src),$(cxx_prog_obj),))

$(call reset_attributes,$1)
endef

# 1 = shared library name
# 2 = shared library path
define cxx_shlib_vars

$(1)_dir := $(dir $(2))


endef


# rule to create C++ shared libraries.
# 1 = shared library name
# 2 = shared library path
# 3 = full pathed sources
# 4 = full pathed object files
define cxx_shlib_rule

# check if srcs variable is set
$(if $(3),,$(error shared library $(1) is missing a $(1)_srcs variable))

# check if version variable is set
$(if $(call version,$1),,$(error shared library $(1) is missing a $(1)_version variable))

# check if minor variable is set
$(if $(call minor,$1),,$(error shared library $(1) is missing a $(1)_minor variable))

# check if release variable is set
$(if $(call release,$1),,$(error shared library $(1) is missing a $(1)_release variable))

# sets the src files cxxflags
$(call create_src_var,$(3),cxxflags,$(call src_cxxflags,$1))

# sets the src files cppflags
$(call create_src_var,$(3),cppflags,$(call src_cppflags,$1))

object_files += $(4)
cxx_shlibs += $(call real_name,$2)
clean_files += $(call linker_name,$2) $(call soname,$2)
sources += $(3)

# library rules

$(call linker_name,$2): $(call real_name,$2)

$(call soname,$2): $(call real_name,$2)

# /path/to/lib/lib<library-name>.so: <prelibs> <object files> | <pre_rule>
$(call real_name,$2): $(call prelib_depends,$1) $(4) | $(call pre_rule,$1)

	$(call gxx,-shared -Wl$(,)-soname$(,)$(notdir $(call soname,$1)) \
                   $(foreach prelib,$(call prelibs,$1),-Wl$(,)-rpath$(,)$(dir $(prelib))) \
                   $(CXXFLAGS) \
                   $(call cxxflags,$1) \
                   $(CPPFLAGS) \
                   $(call cppflags,$1) \
                   $(LDFLAGS) \
                   $(call ldflags,$1) \
                   $(call inc_dirs,$(include_dirs)) \
                   $(call inc_dirs,$(call incdirs,$1)) \
                   $(call lib_dirs,$(call libdirs,$1)) \
                   $(call lib_dirs,$(dir $(call prelibs,$1))) \
                   $(call linkopts,$1) \
                   $(call link_opts_string,$(linker_opts)) \
                   $(call link_libs,$(call libs,$1)) \
                   $(call link_libs,$(notdir $(call prelibs,$1))), \
                   $$@,$$(filter %.$(cxx_shlib_obj),$$^))

	$(call ln,$$(notdir $$@),$$(dir $$@)$(notdir $(call soname,$1)))
	$(call ln,$$(notdir $$@),$$(dir $$@)$(notdir $(call linker_name,$1)))

# generate the rules for the object files
$(foreach src,$(3),$(call obj_rule,$(src),$(cxx_shlib_obj),))

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
