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


# generates the prerequisite libraries for a given target

# 1 = target name
define prereq_libraries
$(foreach prereq_lib,$(call shlibs,$1),$(dollar)$$($(prereq_lib)_shlib_target))
endef


# returns a list of data associated with prerequisite libraries

# 1 = list of prerequisite libraries
# 2 = data to get i.e. (dir)
define library_info
$(foreach prereq_lib,$(1),$($(prereq_lib)_$(2)))
endef


# generates the prerequisites for a given target

# 1 = target
# 2 = target object files
# 3 = module path
define target_prereqs
$(call prereq_libraries,$1) $(2) $(call module_source_fullpath,$(call objs,$1)) $3 $(call target_dir_prereq) | $(call pre_rules,$1)
endef


# Prepends the necessary gcc flag to include directories

# 1 = list of include directores
define prepend_gcc_incdirs
$(patsubst %,-I%,$1)
endef


# Prepends the necessary gcc flags to library directores

# 1 = list of library directories
define prepend_gcc_libdirs
$(patsubst %,-L%,$1)
endef


# Prepends the rpath-link flag to a list of libraries passed in

# 1 = list of library directories
define prepend_gcc_rpath_link
$(foreach dir,$(1),-Wl$(comma)-rpath-link$(comma)$(dir))
endef

# Prepends the necessary gcc flags to a list of libraries to link
# against

# 1 = list of libraries to link against
define prepend_gcc_link_shlibs
$(patsubst %,-l%,$1)
endef


# compiler command for a linked target

# 1 = compiler name
# 2 = compiler flags
# 3 = lib dirs
# 4 = link libraries
define link_target
	$(call $(1),$$(strip $(2)\
            $$(CFLAGS)\
            $$(TARGET_CFLAGS)\
            $$(TARGET_LIBDIRS)\
            $(3)\
            $(call prepend_gcc_libdirs,$(LIBDIRS))\
            $(call prepend_gcc_rpath_link,$(LIBDIRS))\
            $$(call prepend_gcc_libdirs,$$(call library_info,$$(TARGET_SHLIBS),dir))),\
            $$(strip $(4)\
            $$(call prepend_gcc_link_shlibs,$$(TARGET_SHLIBS))),\
            $$@,$$(TARGET_OBJECTS))
endef


# compiler command for a program

# 1 = compiler name
# 2 = compiler flags
# 3 = lib dirs
# 4 = libs
define link_program
$(call link_target,$1,$2 $$(PROG_CFLAGS),$3,$4)
endef


# compiler command for a c++ program

define link_cxx_program
$(call link_program,gxx,$$(CXXFLAGS) $$(PROG_CXXFLAGS),,)
endef


# compiler command for a shared library

# 1 = compiler command
# 2 = soname of shared library
# 3 = compiler flags
# 4 = lib dirs
# 5 = libs
define link_shlib
$(call link_target,$1,-shared $(if $(2),-Wl$(comma)-soname$(comma)$(2))\
                   $3 $$(SHLIB_CFLAGS),\
                   $(4),\
                   $5)
endef


# compiler command for a c++ shared library

# 1 = soname of shared library
define link_cxx_shlib
$(call link_shlib,gxx,$1,$$(CXXFLAGS) $$(SHLIB_CXXFLAGS),,)
endef


# creates a soft link for a shared library

# 1 = link path
# 2 = target
define create_shlib_symlink
$(call ln,$$(notdir $$<),$$(@))
endef


# Generates th recipe for an object file rule

# 1 = cflags
define obj_recipe
$(call cxx_noabbrv,$(strip -M -MM -MD -MT $$@ \
                   $1 $$(CFLAGS) $(SRC_CFLAGS) $(PREREQ_CFLAGS) $(SRC_VAR_CFLAGS) \
                   $(call prepend_gcc_incdirs,$(INCDIRS)) \
                   $(call prepend_gcc_incdirs,$(SRC_INCDIRS)) \
                   $(PREREQ_INCDIRS) \
                   $(SRC_VAR_INCDIRS)),, \
                   $(addsuffix $(SCAFFOLD_DEPENDS_SUFFIX),$@),$<)

	$(call gxx,$(strip $1 \
                   $(CFLAGS) \
                   $(SRC_CFLAGS) \
                   $(PREREQ_CFLAGS) \
                   $(SRC_VAR_CFLAGS) \
                   $(call prepend_gcc_incdirs,$(INCDIRS)) \
                   $(call prepend_gcc_incdirs,$(SRC_INCDIRS)) \
                   $(PREREQ_INCDIRS) \
                   $(SRC_VAR_INCDIRS) \
                   -c),,$@,$<)
endef


# Generates the recipe for a for a C++ object file rule
define cxx_obj_recipe
$(call obj_recipe,$(CXXFLAGS) $(SRC_CXXFLAGS))
endef


# Cancel the predefined implicit rules for C++ object files
%.o: %.cc
%.o: %.cpp

.SECONDEXPANSION:
# Pattern rules for C++ object files
$(SCAFFOLD_BUILD_DIR)%.$(SCAFFOLD_CXX_OBJ_SUFFIX): $(SCAFFOLD_SOURCE_DIR)%.cc $(call implicit_dir_prereq)
	$(call cxx_obj_recipe)

$(SCAFFOLD_BUILD_DIR)%.$(SCAFFOLD_CXX_OBJ_SUFFIX): $(SCAFFOLD_SOURCE_DIR)%.cpp $(call implicit_dir_prereq)
	$(call cxx_obj_recipe)


# creates the target specific variables for all targets

# 1 = target name
# 2 = target path
# 3 = object files
# 3 = Extra prereq cflags
define create_target_vars

$(2): TARGET_CFLAGS := $(call cflags,$1)
$(2): PREREQ_INCDIRS := $(call prepend_gcc_incdirs,$(call srcs_incdirs,$1))
$(2): PREREQ_CFLAGS := $(call srcs_cflags,$1) $4
$(2): TARGET_LIBDIRS := $(call prepend_gcc_libdirs,$(call libdirs,$1))
$(2): TARGET_SHLIBS := $(call shlibs,$1)
$(2): TARGET_OBJECTS := $3 $(call module_source_fullpath,$(call objs,$1))
INCDIRS += $(call set_incdirs,$1)

endef


# sets up the neccessary targets for the objects defined in a
# module.mk
# 1 = module path relative to SCAFFOLD_SOURCE_DIR
define process_module_targets

.PHONY: $(module_dir)clean $(module_dir)clean-pmk

# The target clean rules are prerequisites of the module dir clean
# rule
clean: $(module_dir)clean

# clean rule for removing the pmk files
clean-pmk: $(module_dir)clean-pmk

$(module_dir)clean-pmk:
	rm -f $(call relative_module_to_pmk,$1)

# creates variables for source attributes
$(foreach src,$(local_srcs),$(call src_vars,$(src),\
                                            $(call obj_file,$(call module_source_relpath,$(src)),$(SCAFFOLD_OBJ_SUFFIX))))


# create the rules for the C++ shared libraries
$(foreach shlib,$(local_cxx_shlibs),$(call process_library,$(shlib),\
                                                           $(SCAFFOLD_BUILD_DIR)$(module_dir),\
                                                           $(call module_source_relpath,$(call srcs,$(shlib))),\
                                                           link_cxx_shlib,\
                                                           $(SCAFFOLD_CXX_OBJ_SUFFIX),\
                                                           1,\
                                                           $1 $(call module_source_relpath,$(call module_rules,$1))))


# create the rules for the C++ programs defined in the module
$(foreach prog,$(local_cxx_progs),$(call cxx_prog_rule,$(prog),\
                                                       $(call module_build_fullpath,$(prog)),\
                                                       $(call module_source_relpath,$(call srcs,$(prog))),\
                                                       $(call obj_files,$(call module_source_relpath,$(call srcs,$(prog))),$(SCAFFOLD_CXX_OBJ_SUFFIX)),\
                                                       $1 $(call module_source_relpath,$(call module_rules,$1))))

# Include the makefile that defines any additional rules for this
# module if it exists
$(if $(call module_rules,$1),include $(call module_source_relpath,$(call module_rules,$1)))
endef


# processes libraries both static and shared

# 1 = library name
# 2 = library directory
# 3 = full pathed sources
# 4 = library link command
# 5 = object file suffix
# 6 = build shlib flag
# 7 = module path
define process_library
$(1)_dir := $2

ifneq ($6,)
$(call create_shlib_rule,$1,$(call linker_name,$(2)$(1)),$3,$(call obj_files,$3,$5),$4,$7)
endif
endef


# creates the rule for a shared library

# 1 = shared library name
# 2 = shared library full pathed linker name
# 3 = full pathed sources
# 4 = full pathed object files
# 5 = shared library linker command
# 6 = module path
define create_shlib_rule

# check if srcs variable is set
$(if $(3),,$(error shared library $(1) is missing a $(1)_srcs variable))

$(call add_library,$2)
$(call create_target_vars,$(1),$2,$4,$(SCAFFOLD_FPIC))
$(call add_lib_clean_rule,$1)
$(call add_lib_clean_files,$1,$4)
$(call add_lib_depend_files,$1,$(call depend_files,$(4)))

# used by programs and other libraries to list the necessary
# prerequisites such that the library builds before the targets that
# require it
$(1)_shlib_target := $(2)


# library rules

ifneq ($(call version,$(1)),)

# we have a version number and a minor number, so the linker name depends on the
# soname and the soname depends on the real name
ifneq ($(call minor,$(1)),)

$(call add_lib_clean_files,$1,$(call soname,$(1),$(2)) $(call realname,$(1),$(2)))

$(2): $(call soname,$(1),$(2))
	$(call create_shlib_symlink)

$(call soname,$(1),$(2)): $(call realname,$(1),$(2))
	$(call create_shlib_symlink)

$(call realname,$(1),$(2)): $(call target_prereqs,$1,$4,$6)
	$(call $5,$(call soname,$(1),$(notdir $(2))))


# we have a version number without a minor number, so the linker name
# depends on a soname
else

$(call add_lib_clean_files,$1,$(call soname,$(1),$(2)))

$(2): $(call soname,$(1),$(2))
	$(call create_shlib_symlink)

$(call soname,$(1),$(2)): $(call target_prereqs,$1,$4,$6)
	$(call $5,$(call soname,$(1),$(notdir $(2))))

endif

# no version just build linker name
else

$(call add_lib_clean_files,$1,$2)

$(2): $(call target_prereqs,$1,$4,$6)
	$(call $5,)

endif

endef

# creates the rule for a C++ program

# 1 = program name
# 2 = program full path
# 3 = full pathed program sources
# 4 = full pathed program object files
# 5 = module path
define cxx_prog_rule

# checks to make sure a srcs variable is declared
$(if $(3),,$(error program $(1) is missing a $(1)_srcs variable))

$(call create_target_vars,$(1),$(2),$4)

$(call add_program,$(2))
$(call add_clean_rule,$1)
$(call add_clean_files,$1,$4)
$(call add_depend_files,$1,$(call depend_files,$4))
$(call add_clean_files,$1,$2)


# rule to create the program.  The dependencies are the object files
# obtained from the source files, and the shlibs and libs, and
# pre_rules specified in the module.mk

$(2): $(call target_prereqs,$1,$4,$5)
	$(call link_cxx_program)
endef


# handles local_srcs in a module.mk

# 1 = source file name
# 2 = obj file path
define src_vars

# create a target specific variable for each source attribute
$(2): SRC_VAR_CFLAGS := $(call cflags,$1)
$(2): SRC_VAR_INCDIRS := $(call prepend_gcc_incdirs,$(call incdirs,$1))
endef
