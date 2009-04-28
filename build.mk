# this file should be included by the projects top level Makefile

include $(build_dir)/variables.mk
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
cxx_progs :=
cxx_shlibs :=

# all the dependency files in the project
dependencies := $(shell find -name '*.d')

# module.mk files
modules := $(shell find -name 'module.mk')

.PHONY: clean clean-build clean-targets obj_dirs src_cp programs libraries

ifneq ($(MAKECMDGOALS),clean)
include $(dependencies)
endif

include $(modules)

libraries: obj_dirs $(cxx_shlibs)
programs: obj_dirs $(cxx_progs)
plugins: $(plugins)

obj_dirs: 
	@mkdir -p $(dir $(object_files))

src_cp:
	$(foreach src,$(sources),\
                  $(if $(src)_cp_dest,$(call cp,$(src),$($(src)_cp_dest))))

clean-build:
	rm -f $(shell find -name '*.$(cxx_prog_obj)' -o \
                           -name '*.d' -o \
                           -name '*.$(cxx_shlib_obj)' -o \
                           -name '*~')

	rm -rf $(dir $(object_files))

clean-targets:
	rm -f $(bin_dir)/* \
        $(cxx_progs) \
        $(cxx_shlibs) \
        $(library_dir)/*
