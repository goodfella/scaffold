# Copyright (C) 2009 Nicholas Guiffrida

# generates the rules to build the targets in a module.mk file

# 1 = library name or path
define linker_name
$(dir $1)lib$(notdir $1).so
endef


# returns the soname of a shared library

# 1 = library name
# 2 = linker name
define soname
$(addsuffix .$(call version,$(1)),$(2))
endef


# returns the real name of a shared library

# 1 = library name
# 2 = linker name
define realname
$(addsuffix $(if $(call release,$(1)),.$(call release,$(1)),),$(addsuffix .$(call minor,$(1)),$(addsuffix .$(call version,$(1)),$(2))))
endef


# generates the prelibs for a given object

# 1 = object name
define prelib_depends
$(foreach prelib,$(call prelibs,$1),$($(prelib)_target))
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
           $$(call inc_dirs,$$(src_incdirs)) $3 -c,,$(1),$(2))
endef


# gxx command for a shared library

# 1 = name of shared library
# 2 = soname of library
define compile_cxx_shlib
$(call gxx,-shared $(if $(2),-Wl$(,)-soname$(,)$(2)) \
           $(CXXFLAGS) \
           $(call cxxflags,$1) \
           $(CPPFLAGS) \
           $(call cppflags,$1) \
           $(call inc_dirs,$(include_dirs)) \
           $(call inc_dirs,$(call incdirs,$1)) \
           $(call lib_dirs,$(call libdirs,$1)) \
           $(call lib_dirs,$(foreach prelib,$(call prelibs,$1),$($(prelib)_dir))) \
           $(call linkopts,$1) \
           $(call link_opts_string,$(linker_opts)), \
           $(call link_libs,$(call libs,$1)) \
           $(call link_libs,$(call prelibs,$1)), \
           $$@,$$(filter %.$(obj_file_suffix),$$^))
endef


# creates a soft link for a shared library

# 1 = link path
# 2 = target
define link_shlib
$(call ln,$$(notdir $$<),$$(@))
endef

# creates the depends file for an object file

# 1 = target path
# 2 = infile path
define make_depends
$(call gxx_noabbrv,-M -MM -MD -MT $(1) $(include_dirs:%=-I%) \
           $(call cppflags,$2) $(call inc_dirs,$(call incdirs,$2)),,\
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


# returns a list of data associated with prelibs

# 1 = list of prelibs
# 2 = prelib data to get i.e. (prelibs, prelib-dirs)
define prelib_info
$(foreach prelib,$(1),$(call $(prelib)-$(2)))
endef


# create the rules for the C++ shared libraries
define process_module_vars

$(foreach shlib,$(local_cxx_shlibs),$(call lib_vars,$(shlib),\
                                                    $(call relpath,$(shlib)),\
                                                    $(call linker_name,$(call relpath,$(shlib)))))

$(call reset_module_vars)
endef


# sets up the neccessary targets for the objects defined in a
# module.mk
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
                   $(call lib_dirs,$(call prelib_info,$(call prelibs,$(1)),prelib-dirs)) \
                   $(call lib_dirs,$(call libdirs,$1)) \
                   $(call linkopts,$1) \
                   $(call link_opts_string,$(linker_opts)), \
                   $(call link_libs,$(call libs,$1)) \
                   $(call link_libs,$(call prelib_info,$(call prelibs,$(1)),prelibs)), \
                   $$@,$$(filter %.$(obj_file_suffix),$$^))

# generate the rules for each object file
$(foreach src,$(3),$(call obj_rule,$(src),$(obj_file_suffix),))

$(call reset_attributes,$1)
endef


# Creates the variables associated with a library that are used by
# programs and other libraries that need them.

# 1 = library name
# 2 = library path
# 3 = library target name
define lib_vars

# used by programs to get the directory which contains the library
$(1)_dir := $(dir $(2))

# used by programs and other libraries to list the necessary
# prerequisites such that the library builds before the targets that
# require it
$(1)_target := $(3)

# generates the prelibs recursively
define $(1)-prelibs
$(1) $(foreach prelib,$(call prelibs,$(1)),$$(call $(prelib)-prelibs))
endef

# generates the prelib directories recursively
define $(1)-prelib-dirs
$(dir $(2)) $(foreach prelib,$(call prelibs,$(1)),$$(call $(prelib)-prelib-dirs))
endef


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

ifneq ($(call version,$(1)),)

# we have a version number and a minor number, so the linker name depends on the
# soname and the soname depends on the real name
ifneq ($(call minor,$(1)),)

shlib_clean += $(call soname,$(1),$(2)) $(call realname,$(1),$(2))

$(2): $(call soname,$(1),$(2))
	$(call link_shlib)

$(call soname,$(1),$(2)): $(call realname,$(1),$(2))
	$(call link_shlib)

# /path/to/lib/library-real-name: <prelibs> <object files> | <pre_rule>
$(call realname,$(1),$(2)): $(call prelib_depends,$1) $(4) | $(call pre_rule,$1)
	$(call compile_cxx_shlib,$(1),$(call soname,$(1),$(notdir $(2))))


# we have a version number without a minor number, so the linker name
# depends on a soname
else

shlib_clean += $(call soname,$(1),$(2))

$(2): $(call soname,$(1),$(2))
	$(call link_shlib)

# /path/to/lib/library-real-name: <prelibs> <object files> | <pre_rule>
$(call soname,$(1),$(2)): $(call prelib_depends,$1) $(4) | $(call pre_rule,$1)
	$(call compile_cxx_shlib,$(1),$(call soname,$(1),$(notdir $(2))))

endif

# no version just build linker name
else

# /path/to/lib/library-real-name: <prelibs> <object files> | <pre_rule>
$(2): $(call prelib_depends,$1) $(4) | $(call pre_rule,$1)
	$(call compile_cxx_shlib,$(1),)

endif


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
