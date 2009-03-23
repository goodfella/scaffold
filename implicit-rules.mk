# all the implicit rules


# compiles a single source file into an object file

# 1 = path of source file
# 2 = path of object file
# 3 = extra flags
define compile_source
$(call gxx,$(CXXFLAGS) $(CPPFLAGS) $(include_dirs:%=-I%) $3 \
           $(call cxxflags,$1) \
           $(call cppflags,$1) \
           $(call inc_dirs,$(call incdirs,$2)) -c,$(2),$(1))
endef


# creates the depends file for an object file

# 1 = target path
# 2 = infile path
define make_depends
$(call gxx,-M -MM -MD -MT $1 $(include_dirs:%=-I%) \
           $(call cppflags,$2) $(call inc_dirs,$(call incdirs,$2)),\
           $(addsuffix .d,$1),$2)
endef


# creates the object file for a C++ program
%.$(cxx_prog_obj): %.$(cxx_src_suffix)
	$(call make_depends,$@,$(filter %.$(cxx_src_suffix),$^))
	$(call compile_source,$(filter %.$(cxx_src_suffix),$^),$@,)


# creates an object file with the fpic option for C++ shared libraries
%.$(cxx_sharedlib_obj): %.$(cxx_src_suffix)
	$(call make_depends,$@,$(filter %.$(cxx_src_suffix),$^))
	$(call compile_source,$(filter %.$(cxx_src_suffix),$^),$@,-fpic)


