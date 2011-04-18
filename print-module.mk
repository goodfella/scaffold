scaffold_dir := $(dir $(MAKEFILE_LIST))
include $(scaffold_dir)variables.mk
include $(scaffold_dir)attributes.mk
include $(scaffold_dir)commands.mk
include $(scaffold_dir)module-helper.mk
include $(scaffold_dir)modules.mk


%.mk:

include $(MAKECMDGOALS)

$(info $(call process_module_targets,$(MAKECMDGOALS)))
