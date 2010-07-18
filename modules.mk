# Copyright (C) 2009 Nicholas Guiffrida

# generates the rules to build the targets in a module.mk file

# 1 = library name or path
define linker_name
$(dir $1)lib$(notdir $1).so
endef


# 1 = object name
define prelib_depends
$(foreach prelib,$(call prelibs,$1),$(call linker_name,$($(prelib)_dir)$(prelib)))
endef


# compiles a single source file into an object file

# 1 = path of object file
# 2 = path of source file
# 3 = extra flags
define compile_source
$(call gxx,$(CXXFLAGS) \
           $$(_src_cxxflags) \
           $$(target_cxxflags) \
           $(CPPFLAGS) \
           $$(_src_cppflags) \
           $$(target_cppflags) \
           $(call inc_dirs,$(include_dirs)) \
           $$(call inc_dirs,$$(src_incdirs)) $3 -c,$(1),$(2))
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
$(addsuffix .$(2),$(basename $(1)))
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
$(foreach src,$(local_srcs),$(call src_vars,$(src),\
                                            $(call obj_file,$(call relpath,$(src)),$(obj_file_suffix))))


# create the rules for the C++ shared libraries
$(foreach shlib,$(local_cxx_shlibs),$(call cxx_shlib_rule,$(shlib),\
                                                          $(call linker_name,$(call relpath,$(shlib))),\
                                                          $(call relpath,$(call srcs,$(shlib))),\
                                                          $(call obj_files,$(call relpath,$(call srcs,$(shlib))),$(obj_file_suffix))))

# # create the rules for the C++ programs defined in the module
$(foreach prog,$(local_cxx_progs),$(call cxx_prog_rule,$(prog),\
                                                       $(call relpath,$(prog)),\
                                                       $(call relpath,$(call srcs,$(prog))),\
                                                       $(call obj_files,$(call relpath,$(call srcs,$(prog))),$(obj_file_suffix))))

$(call reset_module_vars)

endef


# creates the rule for an object file

# 1 = source file path
# 2 = object file suffix
# 3 = extra gcc args
define obj_rule
$(call obj_file,$(1),$(2)) : $1
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

# target specific variable for src_cppflags and src_cxxflags
$(2): target_cppflags := $(call src_cppflags,$1)
$(2): target_cxxflags := $(call src_cxxflags,$1)

sources += $(3)
cxx_progs += $(2)
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
                   $(call inc_dirs,$(include_dirs)) \
                   $(call inc_dirs,$(call incdirs,$1)) \
                   $(call lib_dirs,$(foreach prelib,$(call prelibs,$1),$($(prelib)_dir))) \
                   $(call lib_dirs,$(call libdirs,$1)) \
                   $(call linkopts,$1) \
                   $(call link_opts_string,$(linker_opts)) \
                   $(call link_libs,$(call libs,$1)) \
                   $(call link_libs,$(notdir $(call prelibs,$1))), \
                   $$@,$$(filter %.$(obj_file_suffix),$$^))

# generate the rules for each object file
$(foreach src,$(3),$(call obj_rule,$(src),$(obj_file_suffix),))

$(call reset_attributes,$1)
endef

# 1 = shared library name
# 2 = shared library path
define cxx_shlib_vars

$(1)_dir := $(dir $(2))


endef


# rule to create C++ shared libraries.
# 1 = shared library name
# 2 = shared library linker name path
# 3 = full pathed sources
# 4 = full pathed object files
define cxx_shlib_rule

# check if srcs variable is set
$(if $(3),,$(error shared library $(1) is missing a $(1)_srcs variable))

# target specific variables for cppflags and cxxflags
$(2): target_cppflags := $(call src_cppflags,$1)
$(2): target_cxxflags := $(call src_cxxflags,$1)


object_files += $(4)
cxx_shlibs += $(2)
sources += $(3)

# library rules

# /path/to/lib/lib<library-name>.so: <prelibs> <object files> | <pre_rule>
$(2): $(call prelib_depends,$1) $(4) | $(call pre_rule,$1)

	$(call gxx,-shared \
                   $(foreach prelib,$(call prelibs,$1),-Wl$(,)-rpath$(,)$($(prelib)_dir)) \
                   $(CXXFLAGS) \
                   $(call cxxflags,$1) \
                   $(CPPFLAGS) \
                   $(call cppflags,$1) \
                   $(call inc_dirs,$(include_dirs)) \
                   $(call inc_dirs,$(call incdirs,$1)) \
                   $(call lib_dirs,$(call libdirs,$1)) \
                   $(call lib_dirs,$(foreach prelib,$(call prelibs,$1),$($(prelib)_dir))) \
                   $(call linkopts,$1) \
                   $(call link_opts_string,$(linker_opts)) \
                   $(call link_libs,$(call libs,$1)) \
                   $(call link_libs,$(notdir $(call prelibs,$1))), \
                   $$@,$$(filter %.$(obj_file_suffix),$$^))

# generate the rules for the object files
$(foreach src,$(3),$(call obj_rule,$(src),$(obj_file_suffix),-fPIC))

$(call reset_attributes,$1)
endef


# handles local_srcs in a module.mk

# 1 = source file name
# 2 = obj file path
define src_vars

# create a target specific variable for each source attribute the
# underscore is there because there exists attributes for targets that
# match the target specific variable names
$(2): _src_cxxflags := $(call cxxflags,$1)
$(2): _src_cppflags := $(call cppflags,$1)
$(2): src_incdirs := $(call incdirs,$1)
$(call reset_attributes,$1)
endef
