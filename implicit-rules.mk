# all the implicit rules


# compiles a single source file into an object file

# 1 = path of object file
# 2 = path of source file
# 3 = extra flags
define compile_source
$(call gxx,$(CXXFLAGS) \
           $(call cxxflags,$2) \
           $(CPPFLAGS) \
           $(call cppflags,$2) \
           $(call inc_dirs,$(include_dirs)) \
           $(call inc_dirs,$(call incdirs,$2)) -c,$(1),$(2))
endef


# creates the depends file for an object file

# 1 = target path
# 2 = infile path
define make_depends
$(call gxx,-M -MM -MD -MT $(1) $(include_dirs:%=-I%) \
           $(call cppflags,$2) $(call inc_dirs,$(call incdirs,$2)),\
           $(addsuffix .d,$1),$2)
endef


# creates the object file for a C++ program
%.$(cxx_prog_obj):
	$(call make_depends,$@,$(call obj_src,$@,$(cxx_prog_obj),$(cxx_src_suffix)))
	$(call compile_source,$@,$(call obj_src,$@,$(cxx_prog_obj),$(cxx_src_suffix)),)


# creates an object file with the fpic option for C++ shared libraries
%.$(cxx_shlib_obj):
	$(call make_depends,$@,$(call obj_src,$@,$(cxx_shlib_obj),$(cxx_src_suffix)))
	$(call compile_source,$@,$(call obj_src,$@,$(cxx_shlib_obj),$(cxx_src_suffix)),-fpic)


# override so we don't try to build programs from rules not set as
# phony
% : %.$(cxx_prog_obj)


% : %.$(cxx_shlib_obj)