include $(build_dir)/globals.mk
include $(build_dir)/attributes.mk
include $(build_dir)/commands.mk
include $(build_dir)/functions.mk
include $(build_dir)/implicit-rules.mk
include $(build_dir)/modules.mk


# these are variables filled in by the module.mk files

# all the sources
sources :=

# all the object files for binaries
objs :=

# the shared library object files
shared_lib_objs :=

cxxprograms :=
shared_libraries :=
plugins :=

# all the dependency files in the project
dependencies := $(shell find -name '*.d')

# module.mk files
modules := $(shell find -name 'module.mk')

.PHONY: all clean clean-build clean-targets

include $(modules)

libraries: $(shared_libraries)
programs: $(cxxprograms)
plugins: $(plugins)

sources:
	$(foreach src,$(sources),\
                  $(if $(src)_cp_dest,$(call cp,$(src),$($(src)_cp_dest))))

clean-build:
	rm -f $(shell find -name '*.o' -o \
                           -name '*.d' -o \
                           -name '*.$(shared_lib_obj)')

clean-targets:
	rm -f $(shell find -name '*.so*' -o) \
              $(bin_dir)/* \
              $(library_dirs)/*

