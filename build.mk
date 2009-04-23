include $(build_dir)/globals.mk
include $(build_dir)/attributes.mk
include $(build_dir)/commands.mk
include $(build_dir)/functions.mk
include $(build_dir)/implicit-rules.mk
include $(build_dir)/module-helper.mk
include $(build_dir)/modules.mk


# these are variables filled in by the module.mk files

# all the sources
sources :=
object_files :=
cxxprograms :=
shared_libraries :=

# all the dependency files in the project
dependencies := $(shell find -name '*.d')

# module.mk files
modules := $(shell find -name 'module.mk')

.PHONY: clean clean-build clean-targets obj_dirs src_cp programs libraries

ifneq ($(MAKECMDGOALS),clean)
include $(dependencies)
endif

include $(modules)

libraries: obj_dirs $(shared_libraries)
programs: obj_dirs $(cxxprograms)
plugins: $(plugins)

src_cp:
	$(foreach src,$(sources),\
                  $(if $(src)_cp_dest,$(call cp,$(src),$($(src)_cp_dest))))

obj_dirs:
	$(foreach obj,$(object_files),@mkdir -p $(call obj_dirpath,$(obj)))

clean-build:
	rm -f $(shell find -name '*.o' -o \
                           -name '*.d' -o \
                           -name '*.$(cxx_shlib_obj)' -o \
                           -name '*~')

clean-targets:
	rm -f $(bin_dir)/* \
        $(cxxprograms) \
        $(shared_libraries) \
        $(library_dir)/*
