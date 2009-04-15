# all the implicit rules


# compiles a single source file into an object file

# 1 = path of object file
# 2 = path of source file
# 3 = extra flags
define compile_source
$(call gxx,$(CXXFLAGS) $(CPPFLAGS) $(include_dirs:%=-I%) $3 \
           $(call cxxflags,$2) \
           $(call cppflags,$2) \
           $(call inc_dirs,$(call incdirs,$2)) -c,$(call obj_path,$(1)),$(2))
endef


# creates the depends file for an object file

# 1 = target path
# 2 = infile path
define make_depends
$(call gxx,-M -MM -MD -MT $(call obj_dirpath,$1) $(include_dirs:%=-I%) \
           $(call cppflags,$2) $(call inc_dirs,$(call incdirs,$2)),\
           $(call obj_path,$(addsuffix .d,$1)),$2)
endef


# creates the object file for a C++ program
%.o: %.$(cxx_src_suffix)
	$(call make_depends,$@,$(filter %.$(cxx_src_suffix),$^))
	$(call compile_source,$@,$(filter %.$(cxx_src_suffix),$^),)


# creates an object file with the fpic option for C++ shared libraries
%.$(shared_lib_obj): %.$(cxx_src_suffix)
	$(call make_depends,$@,$(filter %.$(cxx_src_suffix),$^))
	$(call compile_source,$@,$(filter %.$(cxx_src_suffix),$^),-fpic)
